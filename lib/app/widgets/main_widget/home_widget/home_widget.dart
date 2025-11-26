import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/home_page/notification_page.dart';
import 'package:webinar/app/pages/main_page/home_page/search_page/suggested_search_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/common/components.dart';

import '../../../../common/common.dart';
import '../../../../common/utils/app_text.dart';
import '../../../../common/utils/object_instance.dart';
import '../../../../config/assets.dart';
import '../../../../config/colors.dart';
import '../../../../config/styles.dart';

class HomeWidget {
  static Widget homeAppBar(
    AnimationController appBarController,
    Animation appBarAnimation,
    String token,
    TextEditingController searchController,
    FocusNode searchNode,
    String name,
  ) {
    bool isLandscape = false; // متغير لتتبع حالة الشاشة
    return AnimatedBuilder(
      animation: appBarAnimation,
      builder: (context, child) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            return Container(
              width: getSize().width,
              height: appBarAnimation.value + 20,
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor ??
                    Colors.blue,
                // استخدام لون الـ AppBar من الثيم
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    bottom: 0,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: SvgPicture.asset(
                        AppAssets.appbarLineSvg,
                        width: getSize().width,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: padding(),
                      child: Column(
                        children: [
                          // app bar
                          Container(
                            width: getSize().width,
                            margin: EdgeInsets.only(
                              top: (!kIsWeb && Platform.isIOS)
                                  ? MediaQuery.of(context).viewPadding.top + 16
                                  : MediaQuery.of(context).viewPadding.top + 22,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        drawerController.showDrawer();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(
                                              0.2), // 20% visible white
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.menu_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        token.isEmpty ? appText.webinar : name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Reward Points
                                    if (token.isNotEmpty) ...{
                                      GestureDetector(
                                        onTap: () {
                                          nextRoute('/reward-points');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFFFA500)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFD700)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.stars_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${userProvider.userPoint ?? 0}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    },
                                    // notification
                                    GestureDetector(
                                      onTap: () {
                                        nextRoute(NotificationPage.pageName);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(
                                              0.2), // 20% visible white
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 20),

                          AnimatedCrossFade(
                            firstChild: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    nextRoute(SuggestedSearchPage.pageName);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                          0.2), // 20% visible white
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search_rounded,
                                          color: Color(0xFF9CA3AF),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            appText.whatSubjectToStudy,
                                            style: GoogleFonts.kufam(
                                              fontSize: 14,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5aad2e)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.tune_rounded,
                                            color: Color(0xFF5aad2e),
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                space(16),
                              ],
                            ),
                            secondChild: SizedBox(width: getSize().width),
                            crossFadeState: (appBarAnimation.value <
                                    (150 +
                                        MediaQuery.of(
                                                navigatorKey.currentContext!)
                                            .viewPadding
                                            .top))
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget titleAndMore(String title,
      {bool isViewAll = true,
      Function? onTapViewAll,
      required BuildContext context}) {
    return Padding(
      padding: padding(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: style20Bold().copyWith(
              color:
                  Theme.of(context).textTheme.titleLarge?.color ?? Colors.white,
            ),
          ),
          const Spacer(),
          if (isViewAll) ...{
            GestureDetector(
              onTap: () {
                if (onTapViewAll != null) {
                  onTapViewAll();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Text(
                appText.viewAll,
                style: style14Regular().copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // اللون الأساسي الثانوي للثيم
                ),
              ),
            )
          }
        ],
      ),
    );
  }

  static Future showFinalizeRegister(int userId) async {
    TextEditingController nameController = TextEditingController();
    FocusNode nameNode = FocusNode();

    TextEditingController referralController = TextEditingController();
    FocusNode referralNode = FocusNode();

    bool isLoading = false;

    return await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  directionality(
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(navigatorKey.currentContext!)
                              .viewInsets
                              .bottom),
                      width: getSize().width,
                      padding: padding(vertical: 21),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText.finalizeYourAccount,
                            style: style16Bold(),
                          ),
                          space(16),
                          input(nameController, nameNode, appText.yourName,
                              iconPathLeft: AppAssets.profileSvg,
                              leftIconSize: 14,
                              isBorder: true),
                          // space(16),
                          // input(
                          //     referralController, referralNode, appText.refCode,
                          //     iconPathLeft: AppAssets.ticketSvg,
                          //     leftIconSize: 14,
                          //     isBorder: true),
                          space(24),
                          Center(
                            child: button(
                                context: context,
                                onTap: () async {
                                  if (nameController.text.length > 3) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    bool res = await AuthenticationService
                                        .registerStep3(
                                            userId,
                                            nameController.text.trim(),
                                            referralController.text.trim());

                                    if (res) {
                                      backRoute(arguments: res);
                                    }

                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                                width: getSize().width,
                                height: 52,
                                text: appText.continue_,
                                bgColor: mainColor(),
                                textColor: Colors.white,
                                isLoading: isLoading),
                          ),
                          space(24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
