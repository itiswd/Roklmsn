class ChapterModel {
  ChapterModel({
    this.id,
    this.title,
    this.topicsCount,
    this.createdAt,
    this.checkAllContentsPass,
    this.items,
  });

  int? id;
  String? title;
  int? topicsCount;
  int? createdAt;
  int? checkAllContentsPass;
  List<ChapterItem>? items;

  ChapterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    topicsCount = json['topics_count'];
    createdAt = json['created_at'];
    checkAllContentsPass = json['check_all_contents_pass'];
    if (json['items'] != null) {
      items = List.from(json['items'])
          .map((e) => ChapterItem.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topics_count': topicsCount,
      'created_at': createdAt,
      'check_all_contents_pass': checkAllContentsPass,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }
}

class ChapterItem {
  ChapterItem({
    this.can,
    this.canViewError,
    this.authHasRead,
    this.type,
    this.createdAt,
    this.link,
    this.id,
    this.title,
    this.fileType,
    this.storage,
    this.volume,
    this.downloadable,
    this.accessAfterDay,
    this.checkPreviousParts,
    this.time,
    this.questionCount,
    this.authStatus,
    this.passed,
  });

  Can? can;
  bool? canViewError;
  bool? authHasRead;
  String? type;
  int? createdAt;
  String? link;
  int? id;
  String? title;

  // for file
  String? fileType;
  String? storage;
  dynamic volume;
  int? downloadable;
  dynamic accessAfterDay;
  int? checkPreviousParts;

  // for quiz
  int? time;
  int? questionCount;
  dynamic authStatus;
  bool? passed;

  ChapterItem.fromJson(Map<String, dynamic> json) {
    can = json['can'] != null ? Can.fromJson(json['can']) : null;
    canViewError = json['can_view_error'];
    authHasRead = json['auth_has_read'];
    type = json['type'];
    createdAt = json['created_at'];
    link = json['link'];
    id = json['id'];
    title = json['title'];
    fileType = json['file_type'];
    storage = json['storage'];
    volume = json['volume'];
    downloadable = json['downloadable'];
    accessAfterDay = json['access_after_day'];
    checkPreviousParts = json['check_previous_parts'];
    time = json['time'];
    questionCount = json['question_count'];
    authStatus = json['auth_status'];
    passed = json['passed'];
  }

  Map<String, dynamic> toJson() {
    return {
      'can': can?.toJson(),
      'can_view_error': canViewError,
      'auth_has_read': authHasRead,
      'type': type,
      'created_at': createdAt,
      'link': link,
      'id': id,
      'title': title,
      'file_type': fileType,
      'storage': storage,
      'volume': volume,
      'downloadable': downloadable,
      'access_after_day': accessAfterDay,
      'check_previous_parts': checkPreviousParts,
      'time': time,
      'question_count': questionCount,
      'auth_status': authStatus,
      'passed': passed,
    };
  }
}

class Can {
  Can({this.view});

  bool? view;

  Can.fromJson(Map<String, dynamic> json) {
    view = json['view'];
  }

  Map<String, dynamic> toJson() {
    return {
      'view': view,
    };
  }
}
