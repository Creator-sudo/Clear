import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setting up background recording automatically when app is launched
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                // Start the recording immediately
                if let rootViewController = appDelegate.window?.rootViewController as? ViewController {
                    rootViewController.startRecording()
                }
            }
            // Move app to background
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
        return true
    }
}
