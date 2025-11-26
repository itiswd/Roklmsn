import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'package:webinar/app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'package:webinar/app/pages/main_page/home_page/chapter_page/chapter_list_page.dart';
import 'package:webinar/app/pages/main_page/home_page/chapter_page/redeem_code.dart';
import 'package:webinar/app/pages/main_page/home_page/enrollment_page/enrollment_page.dart';
import 'package:webinar/app/pages/main_page/home_page/favorites_page/favorites_page.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'package:webinar/app/pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import 'package:webinar/app/pages/main_page/home_page/support_message_page/support_message_page.dart';
import 'package:webinar/app/providers/theme_provider.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/styles.dart';

class ModernDrawer extends StatefulWidget {
  final Function(String) onSelectPage;
  final VoidCallback onLogout;
  final String userName;
  final String? userImageUrl;
  final bool isLoggedIn;
  final String currentPage;

  const ModernDrawer({
    super.key,
    required this.onSelectPage,
    required this.onLogout,
    required this.userName,
    this.userImageUrl,
    required this.isLoggedIn,
    required this.currentPage,
  });

  @override
  State<ModernDrawer> createState() => _ModernDrawerState();
}

class _ModernDrawerState extends State<ModernDrawer> {
  bool hasAccess({bool canRedirect = false}) {
    if (token.isEmpty) {
      showSnackBar(ErrorEnum.alert, appText.youHaveNotAccess);
      if (canRedirect) nextRoute(LoginPage.pageName);
      return false;
    }
    return true;
  }

  // void nextRoute(String route) {
  //   widget.onSelectPage(route);
  // }

  String token = '';
  String? name;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  void getToken() async {
    final t = await AppData.getAccessToken();
    final n = await AppData.getName();
    setState(() => token = t);
    setState(() => name = n);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header

            // Menu Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // buildItem(appText.meetings, AppAssets.meetingsSvg,
                  //     MeetingsPage.pageName),
                  // buildItem(appText.assignments, AppAssets.assignmentsSvg,
                  //     AssignmentsPage.pageName),
                  buildItem(appText.quizzes, AppAssets.quizzesSvg,
                      QuizzesPage.pageName),
                  buildItem(appText.certificates, AppAssets.certificatesSvg,
                      CertificatesPage.pageName),
                  buildItem(appText.favorites, AppAssets.favoritesSvg,
                      FavoritesPage.pageName),
                  buildItem(appText.enrollmentPage, AppAssets.assignmentsSvg,
                      EnrollmentPage.pageName),
                  buildItem(appText.chapter_code, AppAssets.assignmentsSvg,
                      CodePage.pageName),
                  buildItem(appText.chapters, AppAssets.assignmentsSvg,
                      ChapterListPage.pageName),
                  // buildItem(appText.financial, AppAssets.financialSvg,
                  //     FinancialPage.pageName),
                  // buildItem(appText.subscription, AppAssets.subscriptionSvg,
                  //     SubscriptionPage.pageName),
                  buildItem(appText.support, AppAssets.supportSvg,
                      SupportMessagePage.pageName),
                  // buildItem(appText.done_download, AppAssets.downloadableSvg,
                  //     DownloadsPage.pageName),

                  const Divider(),

                  // الوضع الليلي
                  // SwitchListTile(
                  //   title: Text("الوضع الليلي"),
                  //   value: themeProvider.isDarkMode,
                  //   onChanged: (val) => themeProvider.toggleTheme(),
                  // ),

                  const SizedBox(height: 24),

                  // ✅ هنا تضع لغة + تسجيل دخول + التواصل
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اللغة وتسجيل الدخول
                        Row(
                          children: [
                            // GestureDetector(
                            //   onTap: () => MainWidget.showLanguageDialog(),
                            //   child: Row(
                            //     children: [
                            //       ClipRRect(
                            //         borderRadius: BorderRadius.circular(6),
                            //         child: Image.asset(
                            //           '${AppAssets.flags}${locator<AppLanguage>().currentLanguage}.png',
                            //           width: 21,
                            //           height: 20,
                            //           fit: BoxFit.cover,
                            //         ),
                            //       ),
                            //       const SizedBox(width: 6),
                            //       Text(
                            //         locator<AppLanguage>()
                            //                 .appLanguagesData
                            //                 .firstWhere((e) =>
                            //                     e.code!.toLowerCase() ==
                            //                     locator<AppLanguage>()
                            //                         .currentLanguage
                            //                         .toLowerCase())
                            //                 .name ??
                            //             '',
                            //         style: style12Regular()
                            //             .copyWith(color: Colors.black),
                            //       ),
                            //       const SizedBox(width: 6),
                            //       Icon(Icons.keyboard_arrow_down_rounded,
                            //           color: Colors.black.withOpacity(0.6)),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                if (token.isNotEmpty) {
                                  widget.onLogout();
                                } else {
                                  AppData.saveAccessToken('');
                                  nextRoute(LoginPage.pageName);
                                }
                                AppData.saveAccessToken('');
                                nextRoute(LoginPage.pageName);
                              },
                              child: Text(
                                token.isNotEmpty
                                    ? appText.logOut
                                    : appText.login,
                                style: style12Regular()
                                    .copyWith(color: Color(0xFF9CA3AF)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        // الاتصال بنا
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Text(appText.contactUs,
                                  style: style16Bold()
                                      .copyWith(color: Color(0xFF9CA3AF))),
                              const SizedBox(height: 10),
                              GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(
                                        "https://www.facebook.com/share/1ZzPa7rys7/"));
                                  },

                                  child: Text('Developed by Khaled Wael',
                                      style: style13Bold()
                                          .copyWith(color: Color(0xFF9CA3AF)))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.youtube,
                        color: Colors.red),
                    onPressed: () => launchUrl(Uri.parse(
                        "https://youtube.com/@bestmathteacherinegypt?si=j3CT83eQ3zpjkPtc")),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook,
                        color: Colors.blue),
                    onPressed: () => launchUrl(Uri.parse(
                        "https://www.facebook.com/share/1B4sDEB3wt/")),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram,
                        color: Colors.green),
                    onPressed: () => launchUrl(Uri.parse(
                        "https://www.instagram.com/eslam_samhy?igsh=ZHMweXl1ZHgwd2Zl")),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(String label, String icon, String routeName) {
    bool isActive = widget.currentPage == routeName;
    return menuItem(label, icon, () {
      if (hasAccess(canRedirect: true)) nextRoute(routeName);
    }, isActive);
  }

  Widget menuItem(
      String title, String icon, VoidCallback onTap, bool isActive) {
    final activeColor = const Color(0xFF2563EB);
    final inactiveColor = const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          icon,
          width: 22,
          colorFilter: ColorFilter.mode(
              isActive ? activeColor : inactiveColor, BlendMode.srcIn),
        ),
        title: Text(
          title,
          style: GoogleFonts.kufam(
            fontSize: 15.5,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? const Color(0xFF111827) : inactiveColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
