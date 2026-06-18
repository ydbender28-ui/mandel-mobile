import 'package:card_swiper/card_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/order_detail_widget.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/order_search_result_dto.dart';
import 'package:mandel_mobile_app/service/order_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:shimmer/shimmer.dart';

class RecentOrderSwiper extends StatefulWidget {
  const RecentOrderSwiper({super.key});

  @override
  State<RecentOrderSwiper> createState() => _RecentOrderSwiperState();
}

class _RecentOrderSwiperState extends State<RecentOrderSwiper>
    with CommonUtility {
  Map<String, dynamic> filters = <String, dynamic>{"page": 0, "pageSize": 5};

  Future<List<OrderDto>> _getOrderList() async {
    Response response = await OrderService().getOrderList(filters);
    final result = OrderSearchResultDto.fromJson(response.data);
    return result.results!;
  }

  @override
  void initState() {
    super.initState();
    print("Init order swiper");
  }

  @override
  Widget build(BuildContext context) {
    print("Building widget swiper");
    return FutureBuilder(
      future: _getOrderList(),
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
          return Swiper(
            autoplay: true,
            autoplayDelay: 10000,
            itemBuilder: (BuildContext context, int index) {
              return _buildOrderCard(snapshot.data![index], index);
            },
            itemCount: snapshot.data!.length,
            viewportFraction: 0.8,
            scale: 0.9,
          );
        }

        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return _buildEmptyOrderCard();
          },
          loop: false,
          itemCount: 1,
          viewportFraction: 0.8,
          scale: 0.9,
        );
      },
    );
  }

  Widget _buildEmptyOrderCard() {
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
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CommonCustomColor.defaultTextColor),
              'Your orders are empty',
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
            child: const Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: CommonCustomColor.menuItemColor),
                'Looks like you have not order any item to your cart yet!')),
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

  Widget _buildOrderCard(OrderDto orderDto, int index) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => OrderDetailWidget(orderDto: orderDto),
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: RadialGradient(radius: 1.7, colors: [
            buildItemColor(orderDto.orderState!).shade50,
            buildItemColor(orderDto.orderState!).shade100,
          ]),
        ),
        child: Container(
          margin:
              const EdgeInsets.only(top: 10, right: 20, bottom: 10, left: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Order No.#',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${orderDto.id}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CommonCustomColor.menuItemColor),
                      )
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(right: 5),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: buildItemColor(orderDto.orderState!),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          )),
                      Text(
                        '${orderDto.orderState}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: buildItemColor(orderDto.orderState!)),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total ',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      Text('${orderDto.total}',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700))
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Text(
                        'Item count: ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text('${orderDto.lineCount ?? orderDto.orderItems?.length ?? 0}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500))
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: buildOrderProductImages(orderDto),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  MaterialColor buildItemColor(String status) {
    if (CommonConstants.statusComplete == status) {
      return CommonCustomColor.mSuccessColor;
    }
    if (CommonConstants.statusPending == status) {
      return CommonCustomColor.mPendingColor;
    }
    return CommonCustomColor.mDraftColor;
  }

  buildOrderProductImages(OrderDto orderDto) {
    double margin = 0;

    List<Widget> items = [];

    if (null == orderDto.orderItems) {
      items.add(Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: Colors.red,
            border: Border.all(),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
      ));

      return items;
    }

    for (int i = 0; i < orderDto.orderItems!.length; i++) {
      if (i > 2) {
        break;
      }

      String productImageUrl =
          orderDto.orderItems![i].product!.getProductImageUrl();

      items.add(Container(
        margin: EdgeInsets.only(left: margin),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(2)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.network(
            productImageUrl,
            errorBuilder: (context, error, stackTrace) {
              return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 57,
                    height: 57,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  ));
            },
            fit: BoxFit.fitWidth,
            height: MediaQuery.of(context).size.width * 0.2,
            width: MediaQuery.of(context).size.width * 0.2,
          ),
        ),
      ));

      margin += 90;
    }

    return items;
  }
}
