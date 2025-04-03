import Foundation
import Capacitor
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(MyCustomPluginPlugin)
public class AirpayPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MyCustomPluginPlugin"
    public let jsName = "MyCustomPlugin"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "open", returnType: CAPPluginReturnPromise)   
    ]
//    private let implementation = MyCustomPlugin()
    override public func load() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePaymentResponse(_:)), name: Notification.Name("PaymentResponse"), object: nil)
    }

    @objc func handlePaymentResponse(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        notifyListeners("paymentResult", data: userInfo)
    }

   
    @objc func open(_ call: CAPPluginCall) {
        guard let value = call.getString("value") else {
            call.reject("Value not provided")
            return
        }
        
        print("Received JSON String: \(value)")
        
        // Convert JSON string to dictionary
        if let data = value.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Decoded JSON: \(json)")
                    
                    // Pass the JSON dictionary to AppDelegate using NotificationCenter
                    NotificationCenter.default.post(name: Notification.Name("AirPayCall"), object: nil, userInfo: json)
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        
        // Respond back to JavaScript
        call.resolve([
            "value": ""
        ])
        
    }
}



 
