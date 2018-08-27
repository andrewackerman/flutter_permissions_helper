package com.andrewackerman.flutterpermissionshelper;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.security.Permission;
import java.util.HashMap;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPermissionsHelperPlugin */
public class FlutterPermissionsHelperPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener {
    private static final String TAG = "PermissionsHelper";
    private static final String ERROR = "ERROR";

    private Registrar registrar;

    private HashMap<String, Result> resultStore;

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "permissions_helper");
        FlutterPermissionsHelperPlugin plugin = new FlutterPermissionsHelperPlugin(registrar);
        channel.setMethodCallHandler(plugin);
        registrar.addRequestPermissionsResultListener(plugin);
    }

    private FlutterPermissionsHelperPlugin(Registrar registrar) {
        this.registrar = registrar;
        this.resultStore = new HashMap<>();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "hasPermission":
                hasPermission(result, (String)call.argument("permission"));
                break;
            case "requestPermission":
                requestPermission(result, (String)call.argument("permission"));
                break;
            case "getPermissionStatus":
                getPermissionStatus(result, (String)call.argument("permission"));
                break;
            case "openSettings":
                openSettings(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    // region Method Call Handlers

    private void hasPermission(Result result, String permission) {
        String manifest = getManifestFromPermissionString(permission);
        int status = PermissionStatus.Denied;

        switch (permission) {
            case "ACCESS_COARSE_LOCATION":
            case "ACCESS_FINE_LOCATION":
            case "CALL_PHONE":
            case "CAMERA":
            case "READ_CONTACTS":
            case "READ_EXTERNAL_STORAGE":
            case "READ_PHONE_STATE":
            case "READ_SMS":
            case "RECORD_AUDIO":
            case "VIBRATE":
            case "WRITE_CONTACTS":
            case "WRITE_EXTERNAL_STORAGE":
                status = getPermissionStatus(manifest);
                break;

            case "WHEN_IN_USE_LOCATION":
            case "ALWAYS_LOCATION":
                printMergedSupport(permission, "ACCESS_FINE_LOCATION");
                status = getPermissionStatus(manifest);
                break;

            case "PHOTO_LIBRARY":
                printUnsupported(permission);
                break;

            default:
                result.error("PERM_ERROR", String.format("'%s' is not a recognized permission string.", permission), null);
                break;
        }

        result.success(status == PermissionStatus.Granted);
    }

    private void requestPermission(Result result, String permission) {
        String manifest = getManifestFromPermissionString(permission);

        switch (permission) {
            case "ACCESS_COARSE_LOCATION":
            case "ACCESS_FINE_LOCATION":
            case "CALL_PHONE":
            case "CAMERA":
            case "READ_CONTACTS":
            case "READ_EXTERNAL_STORAGE":
            case "READ_PHONE_STATE":
            case "READ_SMS":
            case "RECORD_AUDIO":
            case "VIBRATE":
            case "WRITE_CONTACTS":
            case "WRITE_EXTERNAL_STORAGE":
                resultStore.put(manifest, result);
                requestPermission(manifest);
                break;

            case "WHEN_IN_USE_LOCATION":
            case "ALWAYS_LOCATION":
                printMergedSupport(permission, "ACCESS_FINE_LOCATION");
                resultStore.put(manifest, result);
                requestPermission(manifest);
                break;

            case "PHOTO_LIBRARY":
                printUnsupported(permission);
                result.success(PermissionStatus.Denied);
                break;

            default:
                result.error("PERM_ERROR", String.format("'%s' is not a recognized permission string.", permission), null);
                break;
        }
    }

    private void getPermissionStatus(Result result, String permission) {
        String manifest = getManifestFromPermissionString(permission);
        int status = PermissionStatus.Denied;

        switch (permission) {
            case "ACCESS_COARSE_LOCATION":
            case "ACCESS_FINE_LOCATION":
            case "CALL_PHONE":
            case "CAMERA":
            case "READ_CONTACTS":
            case "READ_EXTERNAL_STORAGE":
            case "READ_PHONE_STATE":
            case "READ_SMS":
            case "RECORD_AUDIO":
            case "VIBRATE":
            case "WRITE_CONTACTS":
            case "WRITE_EXTERNAL_STORAGE":
                status = getPermissionStatus(manifest);
                break;

            case "WHEN_IN_USE_LOCATION":
            case "ALWAYS_LOCATION":
                printMergedSupport(permission, "ACCESS_FINE_LOCATION");
                status = getPermissionStatus(manifest);
                break;

            case "PHOTO_LIBRARY":
                printUnsupported(permission);
                break;

            default:
                result.error("PERM_ERROR", String.format("'%s' is not a recognized permission string.", permission), null);
                break;
        }

        result.success(status);
    }

    private void openSettings(Result result) {
        Activity activity = registrar.activity();
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + activity.getPackageName()));
        intent.addCategory(Intent.CATEGORY_DEFAULT);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        activity.startActivity(intent);

        result.success(true);
    }

    // endregion

    // region Permission Handlers

    private void requestPermission(String manifest) {
        Activity activity = registrar.activity();
        ActivityCompat.requestPermissions(activity, new String[] { manifest }, 0);
    }

    private int getPermissionStatus(String manifest) {
        Activity activity = registrar.activity();
        int status = ContextCompat.checkSelfPermission(activity, manifest);

        if (status == PackageManager.PERMISSION_GRANTED) {
            return PermissionStatus.Granted;
        }

        return PermissionStatus.Denied;
    }

    // endregion

    // region Warning Print Functions

    private void printSynonyms(String a, String b) {
        Log.i(TAG, String.format("Permissions '%s' and '%s' are synonyms on Android.", a, b));
    }

    private void printMergedSupport(String source, String target) {
        Log.i(TAG, String.format("Permission '%s' on Android is treated as '%s'.", source, target));
    }

    private void printUnneeded(String permission) {
        Log.i(TAG, String.format("Requesting the '%s' permission on Android is unnecessary.", permission));
    }

    private void printUnsupported(String permission) {
        Log.i(TAG, String.format("Permission '%s' is unsupported on Android.", permission));
    }

    private void printUnsupportedVersion(String permission, String version) {
        Log.i(TAG, String.format("Permission '%s' is unsupported on Android (%s). Required: Android %s or higher.", permission, Build.VERSION.RELEASE, version));
    }

    // endregion

    // region Common Functions

    private String getManifestFromPermissionString(String permission) {
        switch (permission) {
            case "ACCESS_COARSE_LOCATION":
                return Manifest.permission.ACCESS_COARSE_LOCATION;
            case "ACCESS_FINE_LOCATION":
                return Manifest.permission.ACCESS_FINE_LOCATION;
            case "ALWAYS_LOCATION":
                return Manifest.permission.ACCESS_FINE_LOCATION;
            case "CALL_PHONE":
                return Manifest.permission.CALL_PHONE;
            case "CAMERA":
                return Manifest.permission.CAMERA;
            case "READ_CONTACTS":
                return Manifest.permission.READ_CONTACTS;
            case "READ_EXTERNAL_STORAGE":
                return Manifest.permission.READ_EXTERNAL_STORAGE;
            case "READ_PHONE_STATE":
                return Manifest.permission.READ_PHONE_STATE;
            case "READ_SMS":
                return Manifest.permission.READ_SMS;
            case "RECORD_AUDIO":
                return Manifest.permission.RECORD_AUDIO;
            case "VIBRATE":
                return Manifest.permission.VIBRATE;
            case "WHEN_IN_USE_LOCATION":
                return Manifest.permission.ACCESS_FINE_LOCATION;
            case "WRITE_CONTACTS":
                return Manifest.permission.WRITE_CONTACTS;
            case "WRITE_EXTERNAL_STORAGE":
                return Manifest.permission.WRITE_EXTERNAL_STORAGE;
            default:
                return ERROR;
        }
    }

    // endregion

    // region RequestPermissionsResultListener

    @Override
    public boolean onRequestPermissionsResult(int code, String[] perms, int[] results) {
        int status = PermissionStatus.Undetermined;
        String permission = perms[0];

        if (code == 0 && results.length > 0) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(registrar.activity(), permission)) {
                status = PermissionStatus.Denied;
            } else {
                if (ActivityCompat.checkSelfPermission(registrar.context(), permission) == PackageManager.PERMISSION_GRANTED) {
                    status = PermissionStatus.Granted;
                } else {
                    status = PermissionStatus.DeniedAndDisabled;
                }
            }
        }

        Result result = resultStore.get(permission);
        if (result != null) {
            result.success(status);
        }

        return status == PermissionStatus.Granted;
    }

    // endregion
}
