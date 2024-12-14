import UIKit
import Flutter
import GoogleMaps
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBBx9cLH-urpQQUNbNUYtNkNv5M2RequzM")
        GeneratedPluginRegistrant.register(with: self)
         if FirebaseApp.app() == nil{
              FirebaseApp.configure()
          }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
