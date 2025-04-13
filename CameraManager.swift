import AVFoundation
import UIKit
import Photos
import AVKit

class CameraManager: NSObject {
    private let session = AVCaptureSession()
    private var videoOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var outputURL: URL?

    private var pipController: AVPictureInPictureController?
    private var dummyPlayer: AVPlayer?

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

        setupInvisiblePiP()
    }

    private func setupInvisiblePiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP not supported")
            return
        }

        // Create a 1-second black silent video to make PiP invisible
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: "black", ofType: "mp4") else {
            print("Missing black.mp4 for invisible PiP")
            return
        }

        let url = URL(fileURLWithPath: path)
        dummyPlayer = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: dummyPlayer)
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1) // Invisible layer

        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.startPictureInPicture()
        dummyPlayer?.play()
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
        pipController?.stopPictureInPicture()
        dummyPlayer?.pause()
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {

        guard error == nil else {
            print("Recording error: \(error!.localizedDescription)")
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo library access not granted.")
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { success, error in
                if success {
                    print("Video saved to Photos.")
                } else if let error = error {
                    print("Error saving video: \(error.localizedDescription)")
                }
            }
        }
    }
}
