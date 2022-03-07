#import "AppPackageDataPlugin.h"
#if __has_include(<app_package_data/app_package_data-Swift.h>)
#import <app_package_data/app_package_data-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_package_data-Swift.h"
#endif

@implementation AppPackageDataPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppPackageDataPlugin registerWithRegistrar:registrar];
}
@end
