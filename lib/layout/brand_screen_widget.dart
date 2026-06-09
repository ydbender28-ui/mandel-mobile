import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/brand_product_screen_widget.dart';
import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/service/brand_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

class BrandScreenWidget extends StatefulWidget {
  const BrandScreenWidget({super.key});

  @override
  State<BrandScreenWidget> createState() => _BrandScreenWidgetState();
}

class _BrandScreenWidgetState extends State<BrandScreenWidget> {
  ///
  final _brandService = BrandService();

  ///
  final _searchFieldController = TextEditingController();

  ///
  Map<String, dynamic>? filters = <String, dynamic>{};

  ///
  var status = 1;

  Future<List<BrandDto>> _loadBrandList() async {
    // Response response = await _brandService.getBrandList(filters);
    // List<BrandDto> brandList =
    //     (response.data as List).map((data) => BrandDto.fromJson(data)).toList();
    // return brandList;
    return _brandService.getBrandList(filters);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          _buildFilterField(),
          _buildGridTypes(),
          Visibility(
            visible: status == 0,
            child: _buildBrandList(),
          ),
          Visibility(
            visible: status == 1,
            child: _buildBrandGrid(),
          )
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 20, top: 54, bottom: 20),
      child: const Text(
        'Brands',
        style: TextStyle(
          color: CommonCustomColor.defaultTextColor,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFilterField() {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: IconButton(
              icon: Image.asset(
                'assets/images/mandel_angle_left.png',
                width: 25,
                height: 24,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              enabled: true,
              controller: _searchFieldController,
              onChanged: (value) {
                setState(() {
                  if (_searchFieldController.text.isNotEmpty) {
                    filters!['name'] = _searchFieldController.text;
                  } else {
                    filters!.remove('name');
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for brand',
                hintStyle: const TextStyle(
                    color: CommonCustomColor.menuItemColor, fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFEEEEEE),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                suffixIcon: IconButton(
                  onPressed: _searchFieldController.clear,
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTypes() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          const Spacer(
            flex: 1,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.grid_view,
                  size: 24,
                ),
                onPressed: status == 1
                    ? null
                    : () {
                        setState(() {
                          status = 1;
                        });
                      },
              ),
              IconButton(
                icon: const Icon(
                  Icons.list,
                  size: 24,
                ),
                onPressed: status == 0
                    ? null
                    : () {
                        setState(() {
                          status = 0;
                        });
                      },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBrandList() {
    return FutureBuilder(
      future: _loadBrandList(),
      builder: (BuildContext context, AsyncSnapshot<List<BrandDto>> result) {
        if (result.connectionState == ConnectionState.done && result.hasData) {
          return Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return _buildListItems(context, result.data![index]);
              },
              itemCount: result.data!.length,
            ),
          );
        } else {
          return Flexible(
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: status == 0
                    ? _buildShimmerListView()
                    : _buildShimmerGridView()),
          );
        }
      },
    );
  }

  Widget _buildBrandGrid() {
    return FutureBuilder(
      future: _loadBrandList(),
      builder: (BuildContext context, AsyncSnapshot<List<BrandDto>> result) {
        if (result.connectionState == ConnectionState.done && result.hasData) {
          return Expanded(
            child: GridView.builder(
                itemCount: result.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (_, index) {
                  return Column(
                    children: [
                      Container(
                        width: 86.0,
                        height: 87.0,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: const BoxDecoration(
                          color: CommonCustomColor.fieldColor,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: IconButton(
                          icon: result.data![index].media!.isNotEmpty
                              ? Image.network(
                                  CommonConstants.mandelImageBaseUrl +
                                      result.data![index].media![0].url!,
                                  width: 69,
                                  height: 75,
                                )
                              : Image.asset(
                                  'assets/images/mandel_no_image.jpg',
                                  height: 69,
                                  width: 75,
                                ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BrandProductScreenWidget(
                                  brandDto: result.data![index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            result.data![index].name ??
                                CommonConstants.emptyRecodeIndicator,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }),
          );
        } else {
          return Flexible(
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: status == 0
                    ? _buildShimmerListView()
                    : _buildShimmerGridView()),
          );
        }
      },
    );
  }

  Widget _buildListItems(BuildContext context, BrandDto brandDto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _buildImageView(brandDto),
        title: Text(
          brandDto.name ?? CommonConstants.emptyRecodeIndicator,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BrandProductScreenWidget(brandDto: brandDto)),
          );
        },
      ),
    );
  }

  Widget _buildImageView(BrandDto brandDto) {
    return Container(
      width: 57,
      height: 57,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          border: Border.all(
              color: CommonCustomColor.menuItemColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          margin: const EdgeInsets.all(3),
          child: Center(
              child: brandDto.media!.isNotEmpty
                  ? Image.network(
                      CommonConstants.mandelImageBaseUrl +
                          brandDto.media![0].url!,
                      fit: BoxFit.cover,
                      height: 57,
                      width: 57,
                    )
                  : Image.asset(
                      'assets/images/mandel_no_image.jpg',
                      fit: BoxFit.cover,
                      height: 57,
                      width: 57,
                    )),
        ),
      ),
    );
  }

  Widget _buildShimmerListView() {
    return ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: 15,
        separatorBuilder: (context, index) {
          return const Divider(
            indent: 15.0,
            endIndent: 15.0,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildShimmerLineItem();
        });
  }

  Widget _buildShimmerGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: [..._buildGridViewItem()],
    );
  }

  Widget _buildShimmerLineItem() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            width: 57,
            height: 57,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          SizedBox(
            width: 193,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 200,
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 120,
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  width: 50,
                  height: 30,
                )
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  List<Widget> _buildGridViewItem() {
    List<Widget> items = [];

    for (var i = 0; i < 12; i++) {
      items.add(Column(
        children: [
          Container(
            width: 86.0,
            height: 87.0,
            margin: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              color: CommonCustomColor.fieldColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
              width: 70,
              height: 10,
              decoration: const BoxDecoration(
                color: CommonCustomColor.fieldColor,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ))
        ],
      ));
    }

    return items;
  }
}
