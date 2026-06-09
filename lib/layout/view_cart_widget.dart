import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

class ViewCartWidget extends StatefulWidget {
  final StreamController controller;
  final Function viewCart;

  const ViewCartWidget(
      {super.key, required this.controller, required this.viewCart});

  @override
  State<ViewCartWidget> createState() => _ViewCartWidgetState();
}

class _ViewCartWidgetState extends State<ViewCartWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.controller.stream,
      builder: (context, snapshot) {
        return FutureBuilder(
            future: OrderRepository().isAnyItemExist(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Visibility(
                    visible: true == snapshot.data, child: _buildInit(context));
              }

              return Container();
            });
      },
    );
  }

  Widget _buildInit(BuildContext context) {
    return Column(
      children: [
        _buildSpacer(),
        _buildBottomContainer(context),
      ],
    );
  }

  Widget _buildSpacer() {
    return const Spacer(
      flex: 1,
    );
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0, left: 10, right: 10),
      alignment: Alignment.bottomCenter,
      width: MediaQuery.of(context).size.width,
      height: 87,
      decoration: BoxDecoration(
          color: CommonCustomColor.defaultTextColor,
          borderRadius: BorderRadius.circular(12)),
      child: _buildContainerChild(),
    );
  }

  Widget _buildContainerChild() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: const EdgeInsets.all(15.0),
          width: 150,
          child: Center(
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    minimumSize: const Size.fromHeight(45)),
                onPressed: () {
                  widget.viewCart();
                },
                icon: const Icon(Icons.shopping_cart_rounded),
                label: const Text(
                  "View Cart",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder(
                future: OrderRepository().getOrderItemCount(),
                builder: (context, snapshot) {
                  return Text(
                    '${snapshot.data ?? 0} Item Selected',
                    style: const TextStyle(
                        color: CommonCustomColor.imageCardColor, fontSize: 15),
                  );
                },
              ),
              FutureBuilder(
                future: OrderRepository().getOrderItemsSubTotal(),
                builder: (context, snapshot) {
                  return Text('${snapshot.data ?? 0.0}',
                      style: const TextStyle(
                          color: CommonCustomColor.imageCardColor,
                          fontSize: 24));
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
