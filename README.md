# flutter_permissions_helper

A Flutter package for easily requesting permissions from the mobile OS, prompting the user to grant or deny access to the specified resource. 

Based on the [simple_permissions](https://pub.dartlang.org/packages/simple_permissions) package. This package refactors the code into a more extensible structure and extends support to all mobile OS versions supported by Flutter.

## Requirements

This package is compatable with all versions of Android or iOS that are compatable with Flutter. (Some specific permissions are restricted to certain versions. Details in the permissions reference table below.)

## API Reference

```
static Future<bool> hasPermission(Permission)
```

Checks to see if the app has been granted access to a particular permission.

```
static Future<PermissionStatus> requestPermission(Permission)
```

Requests a permission from the mobile platform. This usually entails a display window showing on the app, asking the user if they would like to allow the app access to that permission.

If the permission has already been granted, this function will automatically return `PermissionStatus.Granted`.

```
static Future<PermissionStatus> getPermissionStatus(Permission)
```

Returns the exact `PermissionStatus` of a given permission.

```
enum Permission
```

An enum containing all the permissions this package supports requesting from the mobile platform.

See Permissions Reference below for a list of values.

```
enum PermissionStatus
```

An enum representing the status of permissions for the app. This enum is returned by several functions illustrating the state of the permission queried.

 - `Undetermined`: The default value for a permission that has not yet been requested.
 - `Restricted`: The permission has been granted but with restrictions on its functionality.
 - `Denied`: The permission has been denied by the user.
 - `DeniedAndDisabled`: The permission has been denied by the user and any further requests are automatically blocked. (Android only)
 - `Granted`: The permission has been granted.

## Permissions Reference

Below is a list of permission codes supported by the plugin and their respective support on each mobile platform. Synonym means a permission is treated as though it is another permission type, usually as a means of convenience. Implicit means that it is not necessary to request the permission on that platform.

| Permission | iOS Support | Android Support |
| --- | --- | --- |
| AccessCourseLocation | Any (Synonym: WHEN_IN_USE_LOCATION) | Any |
| AccessFineLocation | Any (Synonym: WHEN_IN_USE_LOCATION) | Any |
| AlwaysLocation | Any | Any (Synonym: ACCESS_FINE_LOCATION) |
| CallPhone | Not Supported | Any |
| Camera | Any | Any |
| PhotoLibrary | Any | Not Supported |
| ReadContacts | 9.0+ | Any |
| ReadExternalStorage | Any (Implicit) | Any |
| ReadPhoneState | Not Supported | Any |
| ReadSms | Not Supported | Any |
| RecordAudio | Any | Any |
| Vibrate | Not Implemented | Any |
| WhenInUseLocation | Any | Any (Synonym: ACCESS_FINE_LOCATION) |
| WriteContacts | 9.0+ | Any |
| WriteExternalStorage | Any (Implicit) | Any |