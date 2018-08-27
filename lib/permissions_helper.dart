import 'dart:async';

import 'package:flutter/services.dart';

import 'enums.dart';

export 'enums.dart';

class PermissionsHelper {
  static const MethodChannel _channel =
      const MethodChannel('permissions_helper');

  static Future<bool> hasPermission(Permission permission) async {
    final bool hasPerm = await _channel.invokeMethod(
        "hasPermission", {"permission": permissionToString(permission)});
    return hasPerm;
  }

  static Future<PermissionStatus> requestPermission(
      Permission permission) async {
    final int status = await _channel.invokeMethod(
        "requestPermission", {"permission": permissionToString(permission)});

    return intToPermissionStatus(status);
  }

  static Future<PermissionStatus> getPermissionStatus(
      Permission permission) async {
    final int status = await _channel.invokeMethod(
        "getPermissionStatus", {"permission": permissionToString(permission)});
    return intToPermissionStatus(status);
  }

  static Future<bool> openSettings() async {
    final bool isOpen = await _channel.invokeMethod("openSettings");
    return isOpen;
  }
}
