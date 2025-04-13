import AVFoundation
import UIKit

class CameraManager: NSObject {
    private let session = AVCaptureSession()
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var outputURL: URL?

    var isRecording: Bool {
        return videoOutput?.isRecording ?? false
    }

    func startSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("Failed to get camera input")
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureMovieFileOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            self.videoOutput = output
        }

        session.commitConfiguration()
        session.startRunning()
    }

    func startRecording() {
        guard let output = videoOutput else { return }

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("video_\(UUID().uuidString).mov")
        output.startRecording(to: fileURL, recordingDelegate: self)
        self.outputURL = fileURL
    }

    func stopRecording() {
        videoOutput?.stopRecording()
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        print("Recording finished: \(outputFileURL)")
    }
}