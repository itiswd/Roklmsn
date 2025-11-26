import 'dart:async';

import 'package:auto_orientation_v2/auto_orientation_v2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/introduction_page/intro_page.dart';
import 'package:webinar/app/pages/introduction_page/ip_empty_state_page.dart';
import 'package:webinar/app/pages/introduction_page/maintenance_page.dart';
import 'package:webinar/app/pages/main_page/home_page/dashboard_page/reward_point_page.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meeting_details_page.dart';
import 'package:webinar/app/pages/main_page/home_page/payment_status_page/payment_status_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/pdf_viewer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_content_page/web_view_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/pages/offline_page/offline_list_course_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_content_page.dart';
import 'package:webinar/app/pages/offline_page/offline_single_course_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/model/course_model_db.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/config/notification.dart';

import 'app/pages/authentication_page/forget_password_page.dart';
import 'app/pages/authentication_page/verify_code_page.dart';
import 'app/pages/introduction_page/after_splash.dart';
import 'app/pages/introduction_page/custom_splash_page.dart';
import 'app/pages/main_page/blog_page/details_blog_page.dart';
import 'app/pages/main_page/categories_page/categories_page.dart';
import 'app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'app/pages/main_page/classes_page/course_overview_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_history_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignment_overview_page.dart';
import 'app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'app/pages/main_page/home_page/assignments_page/submissions_page.dart';
import 'app/pages/main_page/home_page/cart_page/bank_accounts_page.dart';
import 'app/pages/main_page/home_page/cart_page/cart_page.dart';
import 'app/pages/main_page/home_page/cart_page/checkout_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_details_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'app/pages/main_page/home_page/certificates_page/certificates_student_page.dart';
import 'app/pages/main_page/home_page/chapter_page/chapter_details_page.dart';
import 'app/pages/main_page/home_page/chapter_page/chapter_list_page.dart';
import 'app/pages/main_page/home_page/chapter_page/redeem_code.dart';
import 'app/pages/main_page/home_page/comments_page/comment_details_page.dart';
import 'app/pages/main_page/home_page/comments_page/comments_page.dart';
import 'app/pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import 'app/pages/main_page/home_page/download_page/downloads_page.dart';
import 'app/pages/main_page/home_page/enrollment_page/enrollment_page.dart';
import 'app/pages/main_page/home_page/favorites_page/favorites_page.dart';
import 'app/pages/main_page/home_page/financial_page/financial_page.dart';
import 'app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'app/pages/main_page/home_page/notification_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_info_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quiz_page.dart';
import 'app/pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import 'app/pages/main_page/home_page/search_page/result_search_page.dart';
import 'app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/forum_answer_page.dart';
import 'app/pages/main_page/home_page/single_course_page/forum_page/search_forum_page.dart';
import 'app/pages/main_page/home_page/single_course_page/learning_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_content_page/single_content_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'app/pages/main_page/home_page/single_course_page/single_course_provider.dart';
import 'app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'app/pages/main_page/home_page/support_message_page/conversation_page.dart';
import 'app/pages/main_page/home_page/support_message_page/support_message_page.dart';
import 'app/pages/main_page/main_page.dart';
import 'app/pages/main_page/providers_page/user_profile_page/user_profile_page.dart';
import 'app/providers/app_language_provider.dart';
import 'app/providers/filter_course_provider.dart';
import 'app/providers/page_provider.dart';
import 'app/providers/providers_provider.dart';
import 'app/providers/theme_provider.dart';
import 'app/providers/user_provider.dart';
import 'common/common.dart';
import 'firebase_options.dart';
import 'locator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // showFlutterNotification(message);
  // log('Handling a background message ${message.messageId}');
  // print('notif +: ${message.data}');
  // print('message--');
}

void main() async {
  // debugRepaintRainbowEnabled = true;

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("themeBox");

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  // Capture other errors
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack trace: $stack');
    return true;
  };

  // implemented using window manager
  await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  Hive.registerAdapter(CourseModelDBAdapter());

  await locatorSetup();
  await locator<AppLanguage>().getLanguage();

  await initializeDateFormatting();
  tz.initializeTimeZones();

  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    name: "Eslam",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();
/*
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      if (kDebugMode) {
        print('message-');
      }
    }
    showFlutterNotification(message);
  });

  FirebaseMessaging.instance.getToken().then((value) {
    print('token : ${value}');
  });
*/

  final messaging = FirebaseMessaging.instance;

  await Firebase.initializeApp();

  NotificationSettings settings = await messaging.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Wait for APNs token
    final apnsToken = await messaging.getAPNSToken();
    if (apnsToken != null) {
      final fcmToken = await messaging.getToken();
      // Use fcmToken
      print('token isss: $fcmToken');
    } else {
      // Retry later or listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        // Use token
      });
    }
  }

  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]).then((_) {
  //   runApp(const MyApp());
  // });

  // تمكين جميع التوجهات
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]).then((_) {
  //   runApp(MyApp());
  // });
  runZonedGuarded(() {
    runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // Log native/dart errors (send to Sentry / Crashlytics if available)
    debugPrint('runZonedGuarded caught: $error\n$stack');
    // show errro in loger
    print('runZonedGuarded caught: $error\n$stack');
    // Logger
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> secureScreen() async {
    await FlutterWindowManagerPlus.addFlags(
        FlutterWindowManagerPlus.FLAG_SECURE);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    secureScreen();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    AutoOrientation.portraitAutoMode(forceSensor: true);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => locator<AppLanguageProvider>()),
        ChangeNotifierProvider(create: (context) => locator<PageProvider>()),
        ChangeNotifierProvider(
            create: (context) => locator<FilterCourseProvider>()),
        ChangeNotifierProvider(
            create: (context) => locator<ProvidersProvider>()),
        ChangeNotifierProvider(create: (context) => locator<UserProvider>()),
        ChangeNotifierProvider(create: (context) => locator<DrawerProvider>()),
        ChangeNotifierProvider(create: (_) => SingleCourseProvider()),
      ],
      child: MaterialApp(
        title: appText.webinar,
        navigatorKey: navigatorKey,
        navigatorObservers: <NavigatorObserver>[
          Constants.singleCourseRouteObserver,
          Constants.contentRouteObserver
        ],
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        theme: themeProvider.lightTheme,
        // الوضع النهاري
        darkTheme: themeProvider.darkTheme,
        // الوضع الليلي
        themeMode: themeProvider.themeMode,
        // الوضع الحالي

        // ThemeData(
        //   useMaterial3: false,
        //
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        //   scaffoldBackgroundColor: greyFA,
        //
        // ),

        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,

        initialRoute: SplashPage.pageName,
        routes: {
          MainPage.pageName: (context) => const MainPage(),
          EnrollmentPage.pageName: (context) => const EnrollmentPage(),

          SplashPage.pageName: (context) => const SplashPage(),
          OnboardingScreenOne.pageName: (context) =>
              const OnboardingScreenOne(),
          IntroPage.pageName: (context) => const IntroPage(),
          LoginPage.pageName: (context) => const LoginPage(),
          //RegisterPage.pageName: (context) => const SignupPage(), // mahmoud
          VerifyCodePage.pageName: (context) => const VerifyCodePage(),
          ForgetPasswordPage.pageName: (context) => const ForgetPasswordPage(),
          CategoriesPage.pageName: (context) =>
              const CategoriesPage(), // just for test
          FilterCategoryPage.pageName: (context) => const FilterCategoryPage(),
          SuggestedSearchPage.pageName: (context) =>
              const SuggestedSearchPage(),
          ResultSearchPage.pageName: (context) => const ResultSearchPage(),
          DetailsBlogPage.pageName: (context) => const DetailsBlogPage(),
          SingleCoursePage.pageName: (context) => const SingleCoursePage(),
          LearningPage.pageName: (context) => const LearningPage(),
          SearchForumPage.pageName: (context) => const SearchForumPage(),
          ForumAnswerPage.pageName: (context) => const ForumAnswerPage(),
          NotificationPage.pageName: (context) => const NotificationPage(),
          CartPage.pageName: (context) => const CartPage(),
          CheckoutPage.pageName: (context) => const CheckoutPage(),
          SingleContentPage.pageName: (context) => const SingleContentPage(),
          WebViewPage.pageName: (context) => const WebViewPage(),
          BankAccountsPage.pageName: (context) => const BankAccountsPage(),
          UserProfilePage.pageName: (context) => const UserProfilePage(),
          AssignmentsPage.pageName: (context) => const AssignmentsPage(),
          AssignmentOverviewPage.pageName: (context) =>
              const AssignmentOverviewPage(),
          SubmissionsPage.pageName: (context) => const SubmissionsPage(),
          AssignmentHistoryPage.pageName: (context) =>
              const AssignmentHistoryPage(),
          FinancialPage.pageName: (context) => const FinancialPage(),
          CourseOverviewPage.pageName: (context) => const CourseOverviewPage(),
          MeetingsPage.pageName: (context) => const MeetingsPage(),
          MeetingDetailsPage.pageName: (context) => const MeetingDetailsPage(),
          CommentsPage.pageName: (context) => const CommentsPage(),
          CommentDetailsPage.pageName: (context) => const CommentDetailsPage(),
          SettingPage.pageName: (context) => const SettingPage(),
          QuizzesPage.pageName: (context) => const QuizzesPage(),
          QuizInfoPage.pageName: (context) => const QuizInfoPage(),
          QuizPage.pageName: (context) => const QuizPage(),
          CertificatesPage.pageName: (context) => const CertificatesPage(),
          CertificatesDetailsPage.pageName: (context) =>
              const CertificatesDetailsPage(),
          CertificatesStudentPage.pageName: (context) =>
              const CertificatesStudentPage(),
          SubscriptionPage.pageName: (context) => const SubscriptionPage(),
          FavoritesPage.pageName: (context) => const FavoritesPage(),
          DashboardPage.pageName: (context) => const DashboardPage(),
          SupportMessagePage.pageName: (context) => const SupportMessagePage(),
          ConversationPage.pageName: (context) => const ConversationPage(),
          PdfViewerPage.pageName: (context) => const PdfViewerPage(),
          RewardPointPage.pageName: (context) => const RewardPointPage(),
          MaintenancePage.pageName: (context) => const MaintenancePage(),
          PaymentStatusPage.pageName: (context) => const PaymentStatusPage(),
          IpEmptyStatePage.pageName: (context) => const IpEmptyStatePage(),

          ///
          DownloadsPage.pageName: (context) => const DownloadsPage(),
          CodePage.pageName: (context) => const CodePage(),
          ChapterListPage.pageName: (context) => const ChapterListPage(),
          ChapterDetailsPage.pageName: (context) => const ChapterDetailsPage(),
          // offline pages...
          InternetConnectionPage.pageName: (context) =>
              const InternetConnectionPage(),
          OfflineListCoursePage.pageName: (context) =>
              const OfflineListCoursePage(),
          OfflineSingleCoursePage.pageName: (context) =>
              const OfflineSingleCoursePage(),
          OfflineSingleContentPage.pageName: (context) =>
              const OfflineSingleContentPage(),
        },
      ),
    );
  }
}
