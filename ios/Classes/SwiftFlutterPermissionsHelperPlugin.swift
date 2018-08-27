import Flutter
import UIKit
import AVFoundation
import Photos
import CoreLocation
import Contacts
        
public class SwiftFlutterPermissionsHelperPlugin: NSObject, FlutterPlugin {
    var resultStore = [String:FlutterResult]()
    
    var locationManager = CLLocationManager()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "permissions_helper", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPermissionsHelperPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String:Any]
        switch(call.method) {

        case "hasPermission":
            guard let p = args?["permission"] as? String else {
                result(FlutterError(code: "PERM_ERROR", message: "'permission' argument missing or is the wrong type.", details: nil))
                return
            }

            hasPermission(result, permission: p)

        case "requestPermission":
            guard let p = args?["permission"] as? String else {
                result(FlutterError(code: "PERM_ERROR", message: "'permission' argument missing or is the wrong type.", details: nil))
                return
            }

            requestPermission(result, permission: p)

        case "getPermissionStatus":
            guard let p = args?["permission"] as? String else {
                result(FlutterError(code: "PERM_ERROR", message: "'permission' argument missing or is the wrong type.", details: nil))
                return
            }

            getPermissionStatus(result, permission: p)

        case "openSettings":
            openSettings(result)

        default:
            result(FlutterMethodNotImplemented)
            
        }
    }
}

// MARK: Method Call Handlers

extension SwiftFlutterPermissionsHelperPlugin {

    fileprivate func hasPermission(_ result: @escaping FlutterResult, permission: String) {
        switch (permission) {

        case "ACCESS_COARSE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            result(getWhenInUseLocationPermissionStatus() == .granted)
        case "ACCESS_FINE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            result(getWhenInUseLocationPermissionStatus() == .granted)
        case "ALWAYS_LOCATION":
            result(getAlwaysLocationPermissionStatus() == .granted)
        case "CAMERA":
            result(getCameraPermissionStatus() == .granted)
        case "PHOTO_LIBRARY":
            result(getPhotoLibraryPermissionStatus() == .granted)
        case "READ_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            result(getContactsPermissionStatus() == .granted)
        case "RECORD_AUDIO":
            result(getRecordAudioPermissionStatus() == .granted)
        case "WHEN_IN_USE_LOCATION":
            result(getWhenInUseLocationPermissionStatus() == .granted)
        case "WRITE_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            result(getContactsPermissionStatus() == .granted)

        case "READ_EXTERNAL_STORAGE",
             "WRITE_EXTERNAL_STORAGE":
            printUnneeded(permission)
            result(true)
            
        case "CALL_PHONE",
             "READ_PHONE_STATE",
             "READ_SMS",
             "VIBRATE":
            printUnsupported(permission)
            result(false)

        default:
            result(FlutterError(code: "PERM_ERROR", message: "'\(permission)' is not a recognized permission string.", details: nil))

        }
    }

    fileprivate func getPermissionStatus(_ result: @escaping FlutterResult, permission: String) {
        switch (permission) {

        case "ACCESS_COARSE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            result(getWhenInUseLocationPermissionStatus().rawValue)
        case "ACCESS_FINE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            result(getWhenInUseLocationPermissionStatus().rawValue)
        case "ALWAYS_LOCATION":
            result(getAlwaysLocationPermissionStatus().rawValue)
        case "CAMERA":
            result(getCameraPermissionStatus().rawValue)
        case "PHOTO_LIBRARY":
            result(getPhotoLibraryPermissionStatus().rawValue)
        case "READ_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            result(getContactsPermissionStatus().rawValue)
        case "RECORD_AUDIO":
            result(getRecordAudioPermissionStatus().rawValue)
        case "WHEN_IN_USE_LOCATION":
            result(getWhenInUseLocationPermissionStatus().rawValue)
        case "WRITE_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            result(getContactsPermissionStatus().rawValue)

        case "READ_EXTERNAL_STORAGE",
             "WRITE_EXTERNAL_STORAGE":
            printUnneeded(permission)
            result(PermissionStatus.granted.rawValue)
            
        case "CALL_PHONE",
             "READ_PHONE_STATE",
             "READ_SMS",
             "VIBRATE":
            printUnsupported(permission)
            result(PermissionStatus.denied.rawValue)

        default:
            result(FlutterError(code: "PERM_ERROR", message: "'\(permission)' is not a recognized permission string.", details: nil))

        }
    }

    fileprivate func requestPermission(_ result: @escaping FlutterResult, permission: String) {
        switch (permission) {

        case "ACCESS_COARSE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            requestWhenInUseLocationPermission(result)
        case "ACCESS_FINE_LOCATION":
            printMergedSupport(permission, "WHEN_IN_USE_LOCATION")
            requestWhenInUseLocationPermission(result)
        case "ALWAYS_LOCATION":
            requestAlwaysLocationPermission(result)
        case "CAMERA":
            requestCameraPermission(result)
        case "PHOTO_LIBRARY":
            requestPhotoLibraryPermission(result)
        case "READ_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            requestContactsPermission(result)
        case "RECORD_AUDIO":
            requestRecordAudioPermission(result)
        case "WHEN_IN_USE_LOCATION":
            requestWhenInUseLocationPermission(result)
        case "WRITE_CONTACTS":
            printSynonyms("READ_CONTACTS", "WRITE_CONTACTS")
            requestContactsPermission(result)

        case "READ_EXTERNAL_STORAGE",
             "WRITE_EXTERNAL_STORAGE":
            printUnneeded(permission)
            result(PermissionStatus.granted.rawValue)
            
        case "CALL_PHONE",
             "READ_PHONE_STATE",
             "READ_SMS",
             "VIBRATE":
            printUnsupported(permission)
            result(PermissionStatus.denied.rawValue)

        default:
            result(FlutterError(code: "PERM_ERROR", message: "'\(permission)' is not a recognized permission string.", details: nil))

        }
    }

    fileprivate func openSettings(_ result: @escaping FlutterResult) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    result(true)
                } else {
                    print("[WARNING] 'openSettings' is only available on iOS 10.0 or greater.")
                    result(false)
                }
            }
        }
    }

}

// MARK: Permission Handlers

extension SwiftFlutterPermissionsHelperPlugin {

    // MARK: ALWAYS_LOCATION

    fileprivate func getAlwaysLocationPermissionStatus() -> PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch(status) {
            case .notDetermined:        return .undetermined
            case .restricted:           return .restricted
            case .denied:               return .denied
            case .authorizedAlways:     return .granted
            case .authorizedWhenInUse: 
                print("[WARNING] Location services granted for foreground use only.")
                return .restricted
        }
    }

    fileprivate func requestAlwaysLocationPermission(_ result: @escaping FlutterResult) {
        if (getAlwaysLocationPermissionStatus() == .undetermined) {
            self.resultStore["ALWAYS_LOCATION"] = result
            locationManager.requestAlwaysAuthorization()
        } else {
            result(getAlwaysLocationPermissionStatus() == .granted
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
        }
    }

    // MARK: CAMERA

    fileprivate func getCameraPermissionStatus() -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status) {
            case .notDetermined:  return .undetermined
            case .restricted:     return .restricted
            case .denied:         return .denied
            case .authorized:     return .granted
        }
    }

    fileprivate func requestCameraPermission(_ result: @escaping FlutterResult) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in 
            result(response
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
        }
    }

    // MARK: CONTACTS (READ_CONTACTS, WRITE_CONTACTS)

    fileprivate func getContactsPermissionStatus() -> PermissionStatus {
        if #available(iOS 9.0, *) {
            let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
            switch (status) {
                case .notDetermined:  return .undetermined
                case .restricted:     return .restricted
                case .denied:         return .denied
                case .authorized:     return .granted
            }
        }
        else {
            printUnsupportedVersion("READ_CONTACTS', 'WRITE_CONTACTS'", "9.0")
            return .denied
        }
    }

    fileprivate func requestContactsPermission(_ result: @escaping FlutterResult) {
        if #available(iOS 9.0, *) {
            CNContactStore().requestAccess(for: CNEntityType.contacts) { (access, error) in
                if let e = error {
                    print(e)
                }
                result(access
                    ? PermissionStatus.granted.rawValue
                    : PermissionStatus.denied.rawValue)
            }
        }
        else {
            printUnsupportedVersion("READ_CONTACTS', 'WRITE_CONTACTS'", "9.0")
        }
    }

    // MARK: PHOTO_LIBRARY

    fileprivate func getPhotoLibraryPermissionStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
            case .notDetermined:  return .undetermined
            case .restricted:     return .restricted
            case .denied:         return .denied
            case .authorized:     return .granted
        }
    }

    fileprivate func requestPhotoLibraryPermission(_ result: @escaping FlutterResult) {
        PHPhotoLibrary.requestAuthorization { status in 
            result(status == .authorized
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
        }
    }

    // MARK: RECORD_AUDIO

    fileprivate func getRecordAudioPermissionStatus() -> PermissionStatus {
        let status = AVAudioSession.sharedInstance().recordPermission()
        switch status {
            case .undetermined:     return PermissionStatus.undetermined
            case .denied:           return PermissionStatus.denied
            case .granted:          return PermissionStatus.granted
        }
    }

    fileprivate func requestRecordAudioPermission(_ result: @escaping FlutterResult) {
        if (AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                result(granted
                    ? PermissionStatus.granted.rawValue
                    : PermissionStatus.denied.rawValue)
            })
        }
    }

    // MARK: WHEN_IN_USE_LOCATION (ACCESS_COURSE_LOCATION, ACCESS_FINE_LOCATION)

    fileprivate func getWhenInUseLocationPermissionStatus() -> PermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        switch(status) {
            case .notDetermined:        return .undetermined
            case .restricted:           return .restricted
            case .denied:               return .denied
            case .authorizedAlways:     return .granted
            case .authorizedWhenInUse:  return .granted
        }
    }

    fileprivate func requestWhenInUseLocationPermission(_ result: @escaping FlutterResult) {
        if (getAlwaysLocationPermissionStatus() == .undetermined) {
            self.resultStore["WHEN_IN_USE_LOCATION"] = result
            locationManager.requestWhenInUseAuthorization()
        } else {
            result(getAlwaysLocationPermissionStatus() == .granted
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
        }
    }

}

// MARK: Warning Print Functions

extension SwiftFlutterPermissionsHelperPlugin {

    fileprivate func printSynonyms(_ a: String, _ b: String) {
        print("[INFO] Permissions '\(a)' and '\(b)' are synonymous on iOS.")
    }

    fileprivate func printMergedSupport(_ source: String, _ target: String) {
        print("[INFO] Permission '\(source)' on iOS is treated as '\(target)'.")
    }

    fileprivate func printUnneeded(_ permission: String) {
        print("[INFO] Requesting the '\(permission)' permission on iOS is unnecessary.")
    }

    fileprivate func printUnsupported(_ permission: String) {
        print("[WARNING] '\(permission)' is unsupported on iOS.")
    }

    fileprivate func printUnsupportedVersion(_ permission: String, _ version: String) {
        print("[WARNING] '\(permission)' is unsupported on iOS \(UIDevice.current.systemVersion). Required: iOS \(version) or higher.")
    }

}

// MARK: CLLocationManagerDelegate

extension SwiftFlutterPermissionsHelperPlugin: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let result = self.resultStore["ALWAYS_LOCATION"] {
            result(status == .authorizedAlways
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
            self.resultStore.removeValue(forKey: "ALWAYS_LOCATION")
        } 
        else if let result = self.resultStore["WHEN_IN_USE_LOCATION"] {
            result(status == .authorizedAlways || status == .authorizedWhenInUse
                ? PermissionStatus.granted.rawValue
                : PermissionStatus.denied.rawValue)
            self.resultStore.removeValue(forKey: "WHEN_IN_USE_LOCATION")
        }
    }

}
