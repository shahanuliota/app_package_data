import Flutter
import UIKit

public class SwiftAppPackageDataPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_package_data", binaryMessenger: registrar.messenger())
    let instance = SwiftAppPackageDataPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      
      if(call.method=="getAll"){
       
          let appName: String? = Bundle.main.displayName;
          let packageName: String? = Bundle.main.packageName;
          let buildNumber: String? = Bundle.main.buildNumber;
          
          let version: String? = Bundle.main.version;
          
          let platformData : PlatformData = PlatformData(
          appName: appName ?? "",
          packageName: packageName ?? "",
          buildNumber: buildNumber ?? "",
          version: version ?? "",
          buildSignature:  BuildSignature(
            sha1: "27cd622a46110c9e8d5d13475fc445ee3d659ddf",
            sha256: "9addfac7c1edf5b251af6161e97ed1eca1360468381bc2d39a73e5df1b71ca73",
            md5: "71292a6d85691b6bae8688b0266d1f8b")
          );
          
          let encodedData = try! JSONEncoder().encode(platformData)
          let jsonString = String(data: encodedData,
                                  encoding: .utf8)

         return result(jsonString )
      }
      else if(call.method=="getPlatformVersion"){
          return result("iOS " + UIDevice.current.systemVersion)
      }
      
  
      return  result(FlutterMethodNotImplemented);
  }
}
extension Bundle {
    var displayName: String? {
        var appName:String? =  object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        if(appName == nil){
            appName = object(forInfoDictionaryKey: "CFBundleName") as? String
        }
        

        return appName;
    }
    
    var packageName: String?{
        return object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var version: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var buildNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}



struct PlatformData: Codable {
    
    let appName: String
    let packageName: String
    let buildNumber: String
    let version: String
    let buildSignature: BuildSignature
    
}

struct BuildSignature: Codable{
    let sha1: String
    let sha256: String
    let md5: String
}
