

enum Permission {
  AccessCoarseLocation,
  AccessFineLocation,
  AlwaysLocation,
  CallPhone,
  Camera,
  PhotoLibrary,
  ReadContacts,
  ReadExternalStorage,
  ReadPhoneState,
  ReadSms,
  RecordAudio,
  Vibrate,
  WhenInUseLocation,
  WriteContacts,
  WriteExternalStorage,
}

String permissionToString(Permission permission) {
  switch(permission) {
      case Permission.AccessCoarseLocation:   return 'ACCESS_COARSE_LOCATION';
      case Permission.AccessFineLocation:     return 'ACCESS_FINE_LOCATION';
      case Permission.AlwaysLocation:         return 'ALWAYS_LOCATION';
      case Permission.CallPhone:              return 'CALL_PHONE';
      case Permission.Camera:                 return 'CAMERA';
      case Permission.PhotoLibrary:           return 'PHOTO_LIBRARY';
      case Permission.ReadContacts:           return 'READ_CONTACTS';
      case Permission.ReadExternalStorage:    return 'READ_EXTERNAL_STORAGE';
      case Permission.ReadPhoneState:         return 'READ_PHONE_STATE';
      case Permission.ReadSms:                return 'READ_SMS';
      case Permission.RecordAudio:            return 'RECORD_AUDIO';
      case Permission.Vibrate:                return 'VIBRATE';
      case Permission.WhenInUseLocation:      return 'WHEN_IN_USE_LOCATION';
      case Permission.WriteContacts:          return 'WRITE_CONTACTS';
      case Permission.WriteExternalStorage:   return 'WRITE_EXTERNAL_STORAGE';
      default:                                return '';
  }
}

enum PermissionStatus {
  Undetermined,
  Restricted,
  Denied,
  DeniedAndDisabled,
  Granted,
}

PermissionStatus intToPermissionStatus(int status) {
  if (status >= 0 && status < PermissionStatus.values.length)
    return PermissionStatus.values[status];
  return PermissionStatus.Undetermined;
}