import Flutter
import UIKit
import FBSDKCoreKit

let PLATFORM_CHANNEL = "flutter_facebook_sdk/methodChannel"
let EVENTS_CHANNEL = "flutter_facebook_sdk/eventChannel"

public class SwiftFlutterFacebookSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    var _eventSink: FlutterEventSink?
    var deepLinkUrl:String = ""
    var _queuedLinks = [String]()
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        _queuedLinks.forEach({ events($0) })
        _queuedLinks.removeAll()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterFacebookSdkPlugin()
        
        let channel = FlutterMethodChannel(name: PLATFORM_CHANNEL, binaryMessenger: registrar.messenger())
        
        let eventChannel = FlutterEventChannel(name: EVENTS_CHANNEL, binaryMessenger: registrar.messenger())
        
        eventChannel.setStreamHandler(instance)
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        Settings.setAdvertiserTrackingEnabled(false)
        let launchOptionsForFacebook = launchOptions as? [UIApplication.LaunchOptionsKey: Any]
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
                launchOptionsForFacebook
        )
        AppLinkUtility.fetchDeferredAppLink{ (url, error) in
            if let error = error{
                print("Error %a", error)
            }
            if let url = url {
                self.deepLinkUrl = url.absoluteString
                self.sendMessageToStream(link: self.deepLinkUrl)
            }
        }
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        deepLinkUrl = url.absoluteString
        self.sendMessageToStream(link: deepLinkUrl)
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        //        AppEvents.activateApp()
    }
    
    
    func logEvent( contentType: String,
                   contentData: String,
                   contentId: String,
                   currency: String,
                   price: Double,
                   type: String){
        let parameters = [
            AppEvents.ParameterName.content.rawValue: contentData,
            AppEvents.ParameterName.contentID.rawValue: contentId,
            AppEvents.ParameterName.contentType.rawValue: contentType,
            AppEvents.ParameterName.currency.rawValue: currency
        ]
        switch(type){
        case "addToWishlist":
            AppEvents.logEvent(.addedToWishlist, valueToSum: price, parameters: parameters)
            break
        case "addToCart":
            AppEvents.logEvent(.addedToCart, valueToSum: price, parameters: parameters)
            break
        case "viewContent":
            AppEvents.logEvent(.viewedContent, valueToSum: price, parameters: parameters)
            break
        default:
            break
        }
    }
    
    func logCompleteRegistrationEvent(registrationMethod: String) {
        let parameters = [
            AppEvents.ParameterName.registrationMethod.rawValue: registrationMethod
        ]
        AppEvents.logEvent(.completedRegistration, parameters: parameters)
    }
    
    func logPurchase(amount:Double, currency:String, parameters: Dictionary<String,Any>){
        AppEvents.logPurchase(amount, currency: currency, parameters: parameters)
    }
    
    func logSearchEvent(
        contentType: String,
        contentData: String,
        contentId: String,
        searchString: String,
        success: Bool
    ) {
        let parameters = [
            AppEvents.ParameterName.contentType.rawValue: contentType,
            AppEvents.ParameterName.content.rawValue: contentData,
            AppEvents.ParameterName.contentID.rawValue: contentId,
            AppEvents.ParameterName.searchString.rawValue: searchString,
            AppEvents.ParameterName.success.rawValue: NSNumber(value: success ? 1 : 0)
        ] as [String : Any]
        
        AppEvents.logEvent(.searched, parameters: parameters)
    }
    
    func logInitiateCheckoutEvent(
        contentData: String,
        contentId: String,
        contentType: String,
        numItems: Int,
        paymentInfoAvailable: Bool,
        currency: String,
        totalPrice: Double
    ) {
        let parameters = [
            AppEvents.ParameterName.content.rawValue: contentData,
            AppEvents.ParameterName.contentID.rawValue: contentId,
            AppEvents.ParameterName.contentType.rawValue: contentType,
            AppEvents.ParameterName.numItems.rawValue: NSNumber(value:numItems),
            AppEvents.ParameterName.paymentInfoAvailable.rawValue: NSNumber(value: paymentInfoAvailable ? 1 : 0),
            AppEvents.ParameterName.currency.rawValue: currency
        ] as [String : Any]
        
        AppEvents.logEvent(.initiatedCheckout, valueToSum: totalPrice, parameters: parameters)
    }
    
    func logGenericEvent(args: Dictionary<String, Any>){
        let eventName = args["eventName"] as! String
        let valueToSum = args["valueToSum"] as? Double
        let parameters = args["parameters"] as? Dictionary<String, Any>
        if(valueToSum != nil && parameters != nil){
            AppEvents.logEvent(AppEvents.Name(eventName), valueToSum: valueToSum!, parameters: parameters!)
        }else if(parameters != nil){
            AppEvents.logEvent(AppEvents.Name(eventName), parameters: parameters!)
        }else if(valueToSum != nil){
            AppEvents.logEvent(AppEvents.Name(eventName), valueToSum: valueToSum!)
        }else{
            AppEvents.logEvent(AppEvents.Name(eventName))
        }
    }
    
    func sendMessageToStream(link:String){
        guard let eventSink = _eventSink else {
            _queuedLinks.append(link)
            return
        }
        eventSink(link)
        
    }
    
    private func handleHandleGetAnonymousId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(AppEvents.anonymousID)
    }    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeSDK":
            ApplicationDelegate.initializeSDK(nil)
            result(nil)
            return
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getDeepLinkUrl":
            
            result(deepLinkUrl)
        case "logViewedContent", "logAddToCart", "logAddToWishlist":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
               let contentType = myArgs["contentType"] as? String,
               let contentData = myArgs["contentData"] as? String,
               let contentId = myArgs["contentId"] as? String,
               let currency = myArgs["currency"] as? String,
               let price = myArgs["price"] as? Double {
                //                result("Params received on iOS = \(someInfo1), \(someInfo2)")
                if(call.method.elementsEqual("logViewedContent")){
                    self.logEvent(contentType: contentType, contentData: contentData, contentId: contentId, currency: currency, price: price, type: "viewContent")
                }else if(call.method.elementsEqual("logAddToCart")){
                    self.logEvent(contentType: contentType, contentData: contentData, contentId: contentId, currency: currency, price: price, type: "addToCart")
                }else if(call.method.elementsEqual("logAddToWishlist")){
                    self.logEvent(contentType: contentType, contentData: contentData, contentId: contentId, currency: currency, price: price, type: "addToWishlist")
                }
                result(true)
                return
            } else {
                result(FlutterError(code: "-1", message: "iOS could not extract " +
                                        "flutter arguments in method: (sendParams)", details: nil))
                return
            }
            
        case "activateApp":
            AppEvents.activateApp()
            result(true)
        case "logCompleteRegistration":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
               let registrationMethod = myArgs["registrationMethod"] as? String{
                self.logCompleteRegistrationEvent(registrationMethod: registrationMethod)
                result(true)
                return
            }
        case "logPurchase":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
               let amount = myArgs["amount"] as? Double,
               let currency = myArgs["currency"] as? String,
               let parameters = myArgs["parameters"] as? Dictionary<String, Any>{
                self.logPurchase(amount: amount, currency: currency, parameters: parameters)
                result(true)
                return
            }
            
        case "logSearch":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
               let contentType = myArgs["contentType"] as? String,
               let contentData = myArgs["contentData"] as? String,
               let contentId = myArgs["contentId"] as? String,
               let searchString = myArgs["searchString"] as? String,
               let success = myArgs["success"] as? Bool{
                self.logSearchEvent(contentType: contentType, contentData: contentData, contentId: contentId, searchString: searchString, success: success)
                result(true)
                return
            }
        case "logInitiateCheckout":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any],
               let contentType = myArgs["contentType"] as? String,
               let contentData = myArgs["contentData"] as? String,
               let contentId = myArgs["contentId"] as? String,
               let numItems = myArgs["numItems"] as? Int,
               let paymentInfoAvailable = myArgs["paymentInfoAvailable"] as? Bool,
               let currency = myArgs["currency"] as? String,
               let totalPrice = myArgs["totalPrice"] as? Double{
                self.logInitiateCheckoutEvent(contentData: contentData, contentId: contentId, contentType: contentType, numItems: numItems, paymentInfoAvailable: paymentInfoAvailable, currency: currency, totalPrice: totalPrice)
                result(true)
                return
            }
        case "setAdvertiserTracking":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if  let myArgs = args as? [String: Any],
                let enabled = myArgs["enabled"] as? Bool {
                Settings.setAdvertiserTrackingEnabled(enabled)
                result(enabled)
                return
            }
        case "logEvent":
            guard let args = call.arguments else {
                result(false)
                return
            }
            if let myArgs = args as? [String: Any]{
                logGenericEvent(args: myArgs)
                result(true)
                return
            }
        
        case "getAnonymousId":
            handleHandleGetAnonymousId(call, result: result)
            return

        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
}
