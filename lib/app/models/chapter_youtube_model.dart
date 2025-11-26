class ChapterDetails {
  ChapterDetails({
    this.success,
    this.status,
    this.message,
    this.data,
  });

  bool? success;
  String? status;
  String? message;
  Data? data;

  ChapterDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['success'] = success;
    _data['status'] = status;
    _data['message'] = message;
    _data['data'] = data?.toJson();
    return _data;
  }
}

class Data {
  Data({
    this.id,
    this.title,
    this.description,
    this.canViewError,
    this.authHasRead,
    this.authHasAccess,
    this.userHasAccess,
    this.fileType,
    this.volume,
    this.storage,
    this.createdAt,
    this.downloadLink,
    this.file,
    this.checkPreviousParts,
    this.accessAfterDay,
  });

  int? id;
  String? title;
  dynamic description;
  dynamic canViewError;
  bool? authHasRead;
  bool? authHasAccess;
  bool? userHasAccess;
  String? fileType;
  dynamic volume;
  String? storage;
  int? createdAt;
  String? downloadLink;
  String? file;
  int? checkPreviousParts;
  dynamic accessAfterDay;

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    canViewError = json['can_view_error'];
    authHasRead = json['auth_has_read'];
    authHasAccess = json['auth_has_access'];
    userHasAccess = json['user_has_access'];
    fileType = json['file_type'];
    volume = json['volume'];
    storage = json['storage'];
    createdAt = json['created_at'];
    downloadLink = json['download_link'];
    file = json['file'];
    checkPreviousParts = json['check_previous_parts'];
    accessAfterDay = json['access_after_day'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    _data['description'] = description;
    _data['can_view_error'] = canViewError;
    _data['auth_has_read'] = authHasRead;
    _data['auth_has_access'] = authHasAccess;
    _data['user_has_access'] = userHasAccess;
    _data['file_type'] = fileType;
    _data['volume'] = volume;
    _data['storage'] = storage;
    _data['created_at'] = createdAt;
    _data['download_link'] = downloadLink;
    _data['file'] = file;
    _data['check_previous_parts'] = checkPreviousParts;
    _data['access_after_day'] = accessAfterDay;
    return _data;
  }
}
