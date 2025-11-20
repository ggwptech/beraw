import UIKit
import FirebaseCore
import GoogleSignIn
import ApphudSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    static var dynamicLinksManager: DynamicLinksManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Initialize Apphud
        Apphud.start(apiKey: "app_aXb5X8B3X8T5MTR3NkwSNVMvcjfm9t")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("🚀 AppDelegate: Received URL: \(url)")
        print("🚀 AppDelegate: URL scheme: \(url.scheme ?? "nil")")
        print("🚀 AppDelegate: URL host: \(url.host ?? "nil")")
        
        // Try to handle custom URL scheme (beraw://challenge/123)
        if let dynamicLinksManager = AppDelegate.dynamicLinksManager {
            print("✅ AppDelegate: DynamicLinksManager exists")
            if dynamicLinksManager.handleIncomingLink(url) {
                print("✅ AppDelegate: URL handled by DynamicLinksManager")
                return true
            } else {
                print("⚠️ AppDelegate: URL not handled by DynamicLinksManager")
            }
        } else {
            print("❌ AppDelegate: DynamicLinksManager is nil!")
        }
        
        // Fall back to Google Sign In
        print("🔄 AppDelegate: Passing to Google Sign In")
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
