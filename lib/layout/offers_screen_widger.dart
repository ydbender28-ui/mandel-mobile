import 'dart:async';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';

final List<String> imgList = [
  'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/special-offer-summer-sale-poster-design-template-559042ead839eb74f215c9288ac2e540_screen.jpg?ts=1656994276',
  'https://marketplace.canva.com/EAE7jmjK_ZY/1/0/1131w/canva-super-sale-%28poster%29-U-KMerAfFb0.jpg',
];

class OffersScreenWidget extends StatefulWidget {
  const OffersScreenWidget({super.key});

  @override
  State<OffersScreenWidget> createState() => _OffersScreenWidgetState();
}

class _OffersScreenWidgetState extends State<OffersScreenWidget> {
  int pageIndex = 0;
  int _remainingTime = 3;

  ///
  late Timer _timer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  ///
  ///This method can be used for init timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer.cancel();
          Navigator.pushNamed(context, CommonConstants.configurationScreenUrl);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: PageView(
            children: imgList
                .map((item) => Container(
                      child: Center(
                          child: Image.network(
                        item,
                        fit: BoxFit.cover,
                        height: height,
                      )),
                    ))
                .toList(),
            onPageChanged: (index) {
              setState(() {
                pageIndex = index;
              });
            },
          ),
        ),
        Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50.0, right: 30.0),
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 90,
                height: 36,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, CommonConstants.configurationScreenUrl);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF515151),
                        foregroundColor: Colors.white),
                    child: Text("Skip $_remainingTime")),
              ),
            ),
            Expanded(child: Container()),
            CarouselIndicator(
              width: 10.0,
              height: 10.0,
              activeColor: CommonCustomColor.mandelPrimaryColor,
              color: Colors.white,
              count: imgList.length,
              index: pageIndex,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 50.00),
              child: SizedBox(
                width: 190,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Next"),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
