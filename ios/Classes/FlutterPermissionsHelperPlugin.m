#import "FlutterPermissionsHelperPlugin.h"
#import <flutter_permissions_helper/flutter_permissions_helper-Swift.h>

@implementation FlutterPermissionsHelperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPermissionsHelperPlugin registerWithRegistrar:registrar];
}
@end
