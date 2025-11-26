import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/support_service.dart';
import 'package:webinar/app/widgets/main_widget/support_widget/support_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/locator.dart';

import '../../../../../common/badges.dart';
import '../../../../../common/shimmer_component.dart';
import '../../../../../config/assets.dart';
import '../../../../../config/colors.dart';
import '../../../../../config/styles.dart';
import '../../../../models/course_model.dart';
import '../../../../models/support_model.dart';
import '../../../../providers/filter_course_provider.dart';
import '../../../../services/guest_service/course_service.dart';
import '../../../../widgets/main_widget/home_widget/home_widget.dart';
import '../../categories_page/filter_category_page/filter_category_page.dart';
import 'conversation_page.dart';

class SupportMessagePage extends StatefulWidget {
  static const String pageName = '/support-message';
  const SupportMessagePage({super.key});

  @override
  State<SupportMessagePage> createState() => _SupportMessagePageState();
}

class _SupportMessagePageState extends State<SupportMessagePage>
    with TickerProviderStateMixin {
  late TabController tabController;

  bool isLoadingTickets = false;
  List<SupportModel> ticketsData = [];

  bool isLoadingClasses = false;
  List<SupportModel> classSupportData = [];

  bool isLoadingMyClasss = false;
  List<SupportModel> myClassSupportData = [];

  // New variables for Courses tab
  bool isLoadingCourses = false;
  List<Map<String, dynamic>> coursesData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];
  int currentTab = 0;

  @override
  void initState() {
    super.initState();

    // Update tab count to include Courses
    if (locator<UserProvider>().profile?.roleName != 'user') {
      tabController = TabController(length: 1, vsync: this);
    } else {
      tabController = TabController(length: 1, vsync: this);
    }

    tabController.addListener(() {
      setState(() {
        currentTab = tabController.index;
      });
    });

    getData();
  }

  getData() {
    isLoadingFreeListData = true;
    CourseService.getAll(offset: 0, free: true).then((value) {
      setState(() {
        isLoadingFreeListData = false;
        freeListData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return directionality(
        child: Scaffold(
      appBar: appbar(
          title: appText.support_messages, context: context, leftIcon: null),
      body: Column(
        children: [
          space(6),
          tabBar(
              (p0) {},
              tabController,
              [
                Tab(text: '', height: 1), // New Courses tab
              ],
              context: context),
          space(6),
          Expanded(
              child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  controller: tabController,
                  children: [
                Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: getSize().width,
                          height: getSize().height,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: padding(),
                            scrollDirection: Axis
                                .vertical, // Changed from horizontal to vertical
                            child: Column(
                              // Changed from Row to Column
                              children: List.generate(
                                  isLoadingFreeListData
                                      ? 3
                                      : freeListData.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 16), // Add vertical spacing
                                  child: isLoadingFreeListData
                                      ? loading()
                                      : courseItem(freeListData[index],
                                          context: context),
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ]))
        ],
      ),
    ));
  }
}
