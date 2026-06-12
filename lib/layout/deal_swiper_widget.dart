import 'package:card_swiper/card_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/deal_search_result_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/service/deals_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

class DealSwiperWidget extends StatefulWidget {
  const DealSwiperWidget({super.key});

  @override
  State<DealSwiperWidget> createState() => _DealSwiperWidgetState();
}

class _DealSwiperWidgetState extends State<DealSwiperWidget> {
  Future<List<DealDto>> getDeals() async {
    Map<String, dynamic> filters = <String, dynamic>{
      "page": 0,
      "pageSize": 100
    };

    Response response = await DealsService().getDealList(filters);
    final result = DealSearchResultDto.fromJson(response.data);
    return result.results!
        .where((element) => element.media!.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("disposing deals swiper");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getDeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Swiper(
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  enabled: true,
                  child: const Card());
            },
            itemCount: 2,
            loop: false,
            viewportFraction: 0.9,
            scale: 0.9,
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data!.isNotEmpty) {
            return Swiper(
              autoplay: true,
              autoplayDelay: 10000,
              itemBuilder: (BuildContext context, int index) {
                return _buildDealCard(snapshot.data![index], index);
              },
              itemCount: snapshot.data!.length,
              viewportFraction: 0.8,
              scale: 0.9,
            );
          }
        }

        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return _buildEmptyDealCard();
          },
          loop: false,
          itemCount: 1,
          viewportFraction: 0.8,
          scale: 0.9,
        );
      },
    );
  }

  Widget _buildDealCard(DealDto dealDto, int index) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
              arguments: ProductSearchArguments(
                  filters: {'isOnDeal': true},
                  startingIndex: 1,
                  productDetailsOptions: ProductDetailsOptions(
                      showAddToCart: true, showReturn: false)));
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            CommonConstants.mandelImageBaseUrl + dealDto.media![0].url!,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ));
            },
          ),
        ));
  }

  Widget _buildEmptyDealCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: Image.asset(
              'assets/images/mandel_new_order.png',
              width: 40,
              height: 40,
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            child: const Text(
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CommonCustomColor.defaultTextColor),
              'There are no exclusive offers available for you at the moment',
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
            child: const Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CommonCustomColor.menuItemColor),
                'Stay tuned for upcoming promotions and exciting opportunities!')),
        Container(
          margin: const EdgeInsets.only(left: 50, right: 50),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  minimumSize: const Size.fromHeight(40)),
              onPressed: () {
                Navigator.of(context)
                    .popAndPushNamed(CommonConstants.searchScreenUrl);
              },
              child: const Text(
                "Shop now",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
        )
      ],
    );
  }
}
