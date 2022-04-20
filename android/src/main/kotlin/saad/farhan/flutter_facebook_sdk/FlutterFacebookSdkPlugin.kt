package saad.farhan.flutter_facebook_sdk

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import bolts.AppLinks
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsConstants
import com.facebook.appevents.AppEventsLogger
import com.facebook.applinks.AppLinkData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.NullPointerException
import java.util.*
import kotlin.collections.HashMap
import kotlin.math.log


/** FlutterFacebookSdkPlugin */
class FlutterFacebookSdkPlugin : FlutterPlugin, MethodCallHandler, StreamHandler, ActivityAware, PluginRegistry.NewIntentListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity

    private lateinit var registrar: Registrar
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var logger: AppEventsLogger
    private lateinit var anonymousId: String

    private var deepLinkUrl: String = "Saad Farhan"
    private var PLATFORM_CHANNEL: String = "flutter_facebook_sdk/methodChannel"
    private var EVENTS_CHANNEL: String = "flutter_facebook_sdk/eventChannel"
    private var queuedLinks: List<String> = emptyList()
    private var eventSink: EventSink? = null
    private var context: Context? = null
    private var activityPluginBinding: ActivityPluginBinding? = null

    //  fun registerWith(registrar: Registrar) {
    //    val plugin = FlutterFacebookSdkPlugin()
    //    methodChannel = MethodChannel(registrar.messenger(), PLATFORM_CHANNEL)
    //    methodChannel.setMethodCallHandler(this)
    //  }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, PLATFORM_CHANNEL)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENTS_CHANNEL)
        eventChannel.setStreamHandler(this)

        context = flutterPluginBinding.applicationContext

        anonymousId = AppEventsLogger.getAnonymousAppDeviceGUID(flutterPluginBinding.applicationContext)
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {

            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "getDeepLinkUrl" -> {
                result.success(deepLinkUrl)
            }
            "logViewedContent", "logAddToCart", "logAddToWishlist" -> {
                val args = call.arguments as HashMap<String, Any>
                logEvent(args["contentType"].toString(), args["contentData"].toString(), args["contentId"].toString(), args["currency"].toString(), args["price"].toString().toDouble(), call.method)
            }
            "activateApp" -> {
                logger.logEvent(AppEventsConstants.EVENT_NAME_ACTIVATED_APP)
            }
            "logCompleteRegistration" -> {
                val args = call.arguments as HashMap<String, Any>
                val params = Bundle()
                params.putString(AppEventsConstants.EVENT_PARAM_REGISTRATION_METHOD, args["registrationMethod"].toString())
                logger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION, params)
            }
            "logPurchase" -> {
                val args = call.arguments as HashMap<String, Any>
                logPurchase(args["amount"].toString().toDouble(), args["currency"].toString(), args["parameters"] as HashMap<String, String>)
            }
            "logSearch" -> {
                val args = call.arguments as HashMap<String, Any>
                logSearchEvent(args["contentType"].toString(), args["contentData"].toString(), args["contentId"].toString(), args["searchString"].toString(), args["success"].toString().toBoolean())
            }
            "logInitiateCheckout" -> {
                val args = call.arguments as HashMap<String, Any>
                logInitiateCheckoutEvent(args["contentData"].toString(), args["contentId"].toString(), args["contentType"].toString(), args["numItems"].toString().toInt(), args["paymentInfoAvailable"].toString().toBoolean(), args["currency"].toString(), args["totalPrice"].toString().toDouble())
            }
            "logEvent" -> {
                val args = call.arguments as HashMap<String, Any>
                logGenericEvent(args)
            }
            "getAnonymousId" -> handleGetAnonymousId(call, result)
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun logGenericEvent(args: HashMap<String, Any>) {
        val eventName = args["eventName"] as? String
        val valueToSum = args["valueToSum"] as? Double
        val parameters = args["parameters"] as? HashMap<String, Any>
        if (valueToSum != null && parameters != null) {
            val parameterBundle = createBundleFromMap(args["parameters"] as HashMap<String, Any>)
            logger.logEvent(eventName, valueToSum, parameterBundle)
        } else if (parameters != null) {
            val parameterBundle = createBundleFromMap(args["parameters"] as HashMap<String, Any>)
            logger.logEvent(eventName, parameterBundle)
        } else if (valueToSum != null) {
            logger.logEvent(eventName, valueToSum)
        } else {
            logger.logEvent(eventName)
        }
    }

    private fun logInitiateCheckoutEvent(contentData: String?, contentId: String?, contentType: String?, numItems: Int, paymentInfoAvailable: Boolean, currency: String?, totalPrice: Double) {
        val params = Bundle()
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT, contentData)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
        params.putInt(AppEventsConstants.EVENT_PARAM_NUM_ITEMS, numItems)
        params.putInt(AppEventsConstants.EVENT_PARAM_PAYMENT_INFO_AVAILABLE, if (paymentInfoAvailable) 1 else 0)
        params.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, currency)
        logger.logEvent(AppEventsConstants.EVENT_NAME_INITIATED_CHECKOUT, totalPrice, params)
    }

    private fun logSearchEvent(contentType: String, contentData: String, contentId: String, searchString: String, success: Boolean) {
        val params = Bundle()
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT, contentData)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
        params.putString(AppEventsConstants.EVENT_PARAM_SEARCH_STRING, searchString)
        params.putInt(AppEventsConstants.EVENT_PARAM_SUCCESS, if (success) 1 else 0)
        logger.logEvent(AppEventsConstants.EVENT_NAME_SEARCHED, params)
    }

    private fun logEvent(contentType: String, contentData: String, contentId: String, currency: String, price: Double, type: String) {
        val params = Bundle()
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, contentType)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT, contentData)
        params.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, contentId)
        params.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, currency)
        when (type) {
            "logViewedContent" -> {
                logger.logEvent(AppEventsConstants.EVENT_NAME_VIEWED_CONTENT, price, params)
            }
            "logAddToCart" -> {
                logger.logEvent(AppEventsConstants.EVENT_NAME_ADDED_TO_CART, price, params)
            }
            "logAddToWishlist" -> {
                logger.logEvent(AppEventsConstants.EVENT_NAME_ADDED_TO_WISHLIST, price, params)
            }
        }
    }

    private fun logPurchase(amount: Double, currency: String, parameters: HashMap<String, String>) {
        logger.logPurchase(amount.toBigDecimal(), Currency.getInstance(currency), createBundleFromMap(parameters))
    }

    private fun initFbSdk() {
        FacebookSdk.setAutoInitEnabled(true)
        FacebookSdk.fullyInitialize()
        logger = AppEventsLogger.newLogger(context)

        val targetUri = AppLinks.getTargetUrlFromInboundIntent(context, activityPluginBinding!!.activity.intent)
        AppLinkData.fetchDeferredAppLinkData(context, object : AppLinkData.CompletionHandler {
            override fun onDeferredAppLinkDataFetched(appLinkData: AppLinkData?) {

                if (appLinkData == null) {
                    return;
                }

                deepLinkUrl = appLinkData.targetUri.toString();
                if (eventSink != null && deepLinkUrl != null) {
                    eventSink!!.success(deepLinkUrl)
                }
            }

        })
    }

    private fun createBundleFromMap(parameterMap: Map<String, Any>?): Bundle? {
        if (parameterMap == null) {
            return null
        }

        val bundle = Bundle()
        for (jsonParam in parameterMap.entries) {
            val value = jsonParam.value
            val key = jsonParam.key
            if (value is String) {
                bundle.putString(key, value as String)
            } else if (value is Int) {
                bundle.putInt(key, value as Int)
            } else if (value is Long) {
                bundle.putLong(key, value as Long)
            } else if (value is Double) {
                bundle.putDouble(key, value as Double)
            } else if (value is Boolean) {
                bundle.putBoolean(key, value as Boolean)
            } else if (value is Map<*, *>) {
                val nestedBundle = createBundleFromMap(value as Map<String, Any>)
                bundle.putBundle(key, nestedBundle as Bundle)
            } else {
                throw IllegalArgumentException(
                        "Unsupported value type: " + value.javaClass.kotlin)
            }
        }
        return bundle
    }

    override fun onDetachedFromActivity() {

    }

    private fun handleGetAnonymousId(call: MethodCall, result: Result) {
        result.success(anonymousId)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding!!.removeOnNewIntentListener(this);
        activityPluginBinding = binding;
        binding.addOnNewIntentListener(this);
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        binding.addOnNewIntentListener(this)
        initFbSdk()
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onNewIntent(intent: Intent?): Boolean {
        try {
            // some code
            deepLinkUrl = AppLinks.getTargetUrl(intent).toString()
            eventSink!!.success(deepLinkUrl)
        } catch (e: NullPointerException) {
            // handler
            return false
        }



        return false
    }
}
