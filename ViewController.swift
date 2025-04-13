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

        if cameraManager.isRecording {
            cameraManager.stopRecording()
        } else {
            cameraManager.startRecording()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            }
        }
    }
}