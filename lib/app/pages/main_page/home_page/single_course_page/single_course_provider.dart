import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/models/single_course_model.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/services/user_service/purchase_service.dart';
import 'package:webinar/common/data/app_data.dart';
import '../../../../models/content_model.dart';

class SingleCourseProvider extends ChangeNotifier {
  // Loading states
  bool _isLoading = true;
  bool _isEnrollLoading = false;
  bool _isSubscribeLoading = false;

  // UI states
  bool _viewMore = false;
  bool _showInformationButton = false;
  bool _showContentButton = false;
  bool _canSubmitComment = false;
  bool _canSubmitReview = false;
  bool _isPrivate = false;

  // Data
  SingleCourseModel? _courseData;
  List<CourseModel> _bundleCourses = [];
  List<ContentModel> _contentData = [];
  String _token = '';
  String _name = '';
  int _currentTab = 0;
  bool _isBundleCourse = false;
  int? _commentId;

  // Getters
  bool get isLoading => _isLoading;
  bool get isEnrollLoading => _isEnrollLoading;
  bool get isSubscribeLoading => _isSubscribeLoading;
  bool get viewMore => _viewMore;
  bool get showInformationButton => _showInformationButton;
  bool get showContentButton => _showContentButton;
  bool get canSubmitComment => _canSubmitComment;
  bool get canSubmitReview => _canSubmitReview;
  bool get isPrivate => _isPrivate;

  SingleCourseModel? get courseData => _courseData;
  List<CourseModel> get bundleCourses => _bundleCourses;
  List<ContentModel> get contentData => _contentData;
  String get token => _token;
  String get name => _name;
  int get currentTab => _currentTab;
  bool get isBundleCourse => _isBundleCourse;
  int? get commentId => _commentId;

  // Initialize with course parameters
  Future<void> initialize({
    required int courseId,
    required bool isBundleCourse,
    int? commentId,
    bool isPrivate = false,
    SingleCourseModel? existingCourseData,
  }) async {
    _isLoading = true;
    _commentId = commentId;
    _isPrivate = isPrivate;
    _isBundleCourse = isBundleCourse;
    _courseData = existingCourseData;
    notifyListeners();

    await _loadInitialData(courseId);
  }

  Future<void> _loadInitialData(int courseId) async {
    try {
      _token = await AppData.getAccessToken();
      _name = await AppData.getName();

      await Future.delayed(const Duration(milliseconds: 500));

      log('is Bundle: $_isBundleCourse - id: $courseId');

      _courseData = await CourseService.getSingleCourseData(
          courseId,
          _isBundleCourse,
          isPrivate: _isPrivate
      );

      if (_courseData != null && _isBundleCourse) {
        await _getBundleCourses();
      }

      if (!_isBundleCourse) {
        await _getContent();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error loading course data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getContent() async {
    if (_courseData?.id != null) {
      try {
        _contentData = await CourseService.getContent(_courseData!.id!);
        notifyListeners();
      } catch (e) {
        log('Error loading content: $e');
      }
    }
  }

  Future<void> _getBundleCourses() async {
    if (_courseData?.id != null) {
      try {
        _bundleCourses = await CourseService.bundleCourses(_courseData!.id!);
        notifyListeners();
      } catch (e) {
        log('Error loading bundle courses: $e');
      }
    }
  }

  void toggleViewMore() {
    _viewMore = !_viewMore;
    notifyListeners();
  }

  void onChangeTab(int index) {
    _currentTab = index;
    _offAllTabs();

    switch (index) {
      case 0:
        _showInformationButton = true;
        break;
      case 1:
        _showContentButton = true;
        break;
      case 2:
        _canSubmitReview = true;
        break;
      case 3:
        _canSubmitComment = true;
        break;
    }
    notifyListeners();
  }

  void _offAllTabs() {
    _showContentButton = false;
    _showInformationButton = false;
    _canSubmitReview = false;
    _canSubmitComment = false;
  }

  void updateTabVisibility({
    bool? showInformation,
    bool? showContent,
    bool? canReview,
    bool? canComment,
  }) {
    if (showInformation != null) {
      _offAllTabs();
      _showInformationButton = showInformation;
    }
    if (showContent != null) {
      _offAllTabs();
      _showContentButton = showContent;
    }
    if (canReview != null) {
      _offAllTabs();
      _canSubmitReview = canReview;
    }
    if (canComment != null) {
      _offAllTabs();
      _canSubmitComment = canComment;
    }
    notifyListeners();
  }

  Future<bool> enrollCourse() async {
    if (_courseData == null) return false;

    _isEnrollLoading = true;
    notifyListeners();

    try {
      bool result = false;

      if ((_courseData?.price ?? 0) == 0) {
        result = _isBundleCourse
            ? await PurchaseService.bundlesFree(_courseData!.id!)
            : await PurchaseService.courseFree(_courseData!.id!);

        if (result) {
          await refresh();
        }
      } else {
        await CartService.requestCourse(_courseData!.id!);
        result = true;
      }

      _isEnrollLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      log('Error enrolling course: $e');
      _isEnrollLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> subscribeCourse() async {
    if (_courseData == null) return false;

    _isSubscribeLoading = true;
    notifyListeners();

    try {
      bool result = await CartService.subscribeApplay(_courseData!.id!);

      if (result) {
        await refresh();
      }

      _isSubscribeLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      log('Error subscribing to course: $e');
      _isSubscribeLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    if (_courseData?.id != null) {
      await _loadInitialData(_courseData!.id!);
    }
  }

  void showCommentSection(ScrollController scrollController) {
    if (_commentId == null || _courseData == null) return;

    _currentTab = 3;
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      for (var i = 0; i < (_courseData?.comments.length ?? 0); i++) {
        if (_commentId == _courseData?.comments[i].id) {
          final targetPosition = (_courseData!.comments[i].globalKey.findWidget ?? 0.0);
          scrollController.animateTo(
            targetPosition > 230 ? targetPosition - 230 : 0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.linearToEaseOut,
          );
        }
      }
      _commentId = null;
    });
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}