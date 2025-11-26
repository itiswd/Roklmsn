import 'package:flutter/material.dart';
import 'package:webinar/app/models/category_model.dart';
import 'package:webinar/app/models/course_model.dart';
import 'package:webinar/app/models/filter_model.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/dynamiclly_filter.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/options_filter.dart';
import 'package:webinar/app/providers/filter_course_provider.dart';
import 'package:webinar/app/services/guest_service/categories_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/tablet_detector.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

import '../../../../services/guest_service/course_service.dart';
import '../../../../../common/components.dart';
import '../../../../widgets/main_widget/home_widget/home_widget.dart';

class FilterCategoryPage extends StatefulWidget {
  static const String pageName = '/filter-caregory';
  const FilterCategoryPage({super.key});

  @override
  State<FilterCategoryPage> createState() => _FilterCategoryPageState();
}

class _FilterCategoryPageState extends State<FilterCategoryPage> {

  bool isLoading = false;
  bool isGrid=false;

  
  CategoryModel? category;

  List<CourseModel> data = [];
  List<CourseModel> featuredListData = [];
  List<FilterModel> filters = [];
  
  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;




  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      // if(ModalRoute.of(context)!.settings.arguments != null){
        category = (ModalRoute.of(context)!.settings.arguments as CategoryModel?);

        getData();
        getFilters();
        getFeatured();
      // }
    });

    scrollController.addListener(() {
      var min = scrollController.position.pixels;
      var max = scrollController.position.maxScrollExtent;

      if((max - min) < 300){
        if(!isLoading){
          getData();
        }
      }

    });

    
  }

  getData() async {

    setState(() {
      isLoading = true;
    });
    

    data += await CourseService.getAll(
      offset: data.length, 
      cat: category?.id?.toString(),
      filterOption: locator<FilterCourseProvider>().filterSelected,
      upcoming: locator<FilterCourseProvider>().upcoming,
      free: locator<FilterCourseProvider>().free,
      discount: locator<FilterCourseProvider>().discount,
      downloadable: locator<FilterCourseProvider>().downloadable,
      sort: locator<FilterCourseProvider>().sort,
      bundle: locator<FilterCourseProvider>().bundleCourse,
      reward: locator<FilterCourseProvider>().rewardCourse
    );
    
    setState(() {
      isLoading = false;
    });
  }

  getFilters() async {
    if(category != null){
      filters = await CategoriesService.getFilters(category!.id!);

      locator<FilterCourseProvider>().filters = filters;

      setState(() {});
    }
  }

  getFeatured(){
    if(category != null){
      CourseService.featuredCourse(cat: category!.id!.toString()).then((value) {
        setState(() {
          featuredListData = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
        
    return directionality(
      child: Scaffold(

        appBar: appbar(
          title:appText.courses,
          leftIcon: AppAssets.backSvg,
          onTapLeftIcon: (){
            backRoute();
          },
          isBasket: true, context: context
        ),

        body: Column(
          children: [

            // List 
            
            Expanded(
              child: data.isEmpty && featuredListData.isEmpty && !isLoading
                ? emptyState(AppAssets.filterEmptyStateSvg, appText.dataNotFound, appText.dataNotFoundDesc)
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        if(featuredListData.isNotEmpty)...{
                          
                          // Featured Classes
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeWidget.titleAndMore(appText.featuredClasses, isViewAll: false, context: context),

                              SizedBox(
                                width: getSize().width,
                                height: 215,
                                child: PageView(
                                  controller: sliderPageController,
                                  onPageChanged: (value) async {
                                    
                                    await Future.delayed(const Duration(milliseconds: 500));
                                    
                                    setState(() {
                                      currentSliderIndex = value;
                                    });
                                  },
                                  physics: const BouncingScrollPhysics(),
                                  children: List.generate(featuredListData.length, (index) {
                                    return courseItem(
                                      featuredListData[index], context: context,
                                      
                                    );
                                  }),
                                ),
                              ),
                              
                              space(18),

                              // indecator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ...List.generate(featuredListData.length, (index) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: currentSliderIndex == index ? 16 : 7,
                                      height: 7,
                                      margin: padding(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: mainColor(),
                                        borderRadius: borderRadius()
                                      ),
                                    );

                                  }),
                                ],
                              ),

                              space(14),
                            ],
                          ),

                        },

                        space(14),
                        
                        
                        // list data
                        SizedBox(
                          width: getSize().width,
                          child: isGrid
                        ? GridView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 40
                            ),
                            physics: const NeverScrollableScrollPhysics(),

                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: TabletDetector.isTablet() ? 3 : 2,
                              mainAxisExtent: 190,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16
                            ),
                            
                            children: List.generate((isLoading && data.isEmpty) ? 8 : data.length, (index) {
                              return (isLoading && data.isEmpty)
                                ? courseItemShimmer()
                                : courseItem(
                                    data[index],
                                    width: getSize().width / 2,
                                    
                                    endCardPadding: 0.0,
                                    height: 200.0,
                                    isShowReward: locator<FilterCourseProvider>().rewardCourse, context: context
                                  );
                            }),
                          )

                        : ListView(
                            shrinkWrap: true,
                            children: List.generate((isLoading && data.isEmpty) ? 8 : data.length, (index) {

                              return (isLoading && data.isEmpty)
                                ? courseItemVerticallyShimmer() 
                                : courseItem(
                                    data[index],
                                    isShowReward: locator<FilterCourseProvider>().rewardCourse, context: context
                                  );

                            }),
                          ),

                        ),

                      ],
                    ),
                  )
            )
        
          ],
        ),

      )
    );
  }


  @override
  void dispose() {
    locator<FilterCourseProvider>().clearFilter();
    super.dispose();
  }
}


