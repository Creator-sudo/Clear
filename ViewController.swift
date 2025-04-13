import UIKit

class ViewController: UIViewController {
    let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        cameraManager.startSession()
        startRecordingAndBackground()
    }

    func startRecordingAndBackground() {
        cameraManager.startRecording()
        
        // After starting recording, immediately move the app to the background
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
}
