import UIKit
import Flutter
import EventKitUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, EKEventEditViewDelegate  {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        let methodChannel = FlutterMethodChannel(name: "sample.poumason.dev/channels", binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if (call.method == "shared") {
                self.showSharedActivityViewController(arguments: call.arguments)
                result("OK")
                return
            }
            
            result(FlutterMethodNotImplemented)
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func showSharedActivityViewController(arguments: Any?) {
        if let args = arguments as? Dictionary<String, Any?> , !args.isEmpty {
            
            guard let url = args["url"] as? String, !url.isEmpty else {
                print("no any be shared data")
                return
            }
            
            // 把傳入的資料裝到一個自訂的 Event 資料結構
            let event = Event.init(title: args["title"] as? String,
                                   location: args["location"] as? String,
                                   url: args["url"] as? String,
                                   startDate: args["startDate"] as? Double,
                                   endDate: args["endDate"] as? Double)
            
            let items: [Any]
            let activities: [UIActivity]?
            
            if (event.isValidated()) {
                items = [ url, event ]
                activities = [ EventActivity() ]
            } else {
                items = [ url ]
                activities = nil
            }
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: activities)
            self.window.rootViewController?.present(activityVC, animated: true, completion:  nil)
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction)
    {
        print(action)
        controller.dismiss(animated: true, completion: nil)
    }
}
