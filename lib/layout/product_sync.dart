import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/brand_repository.dart';
import 'package:mandel_mobile_app/db/repository/category_repository.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/db/repository/product_repository.dart';
import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/model/size_dto.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProductSync extends StatefulWidget {
  final bool? showSkip;

  const ProductSync({super.key, this.showSkip = false});

  @override
  State<ProductSync> createState() => _ProductSyncState();
}

class _ProductSyncState extends State<ProductSync> with CommonUtility {
  final configRepo = ConfigsRepository();
  final productRepo = ProductRepository();
  final categoryRepo = CategoryRepository();
  final brandRepo = BrandRepository();
  DownlaodStatus status = DownlaodStatus.pending;
  String title = "Update Product Catalogue";
  String subTitle =
      "Update product catalogue to include latest deals and offers";
  int totalCount = 0;
  int downloadedCount = 0;
  double _percent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: TextStyle(fontSize: 24),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 50, right: 50, bottom: 50),
              child: Text(
                subTitle,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            if (DownlaodStatus.pending == status ||
                status == DownlaodStatus.failed)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 50, right: 50, bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40)),
                  child: const Text(
                    "Update",
                    style: TextStyle(fontSize: 18),
                  ),
                  onPressed: () async {
                    // Navigator.of(context).pop();

                    try {
                      setState(() {
                        status = DownlaodStatus.downloading;
                        title = "Downloading Products";
                        subTitle = "This may take few seconds";
                      });

                      List<ProductDto> products = await getAllPages();
                      await productRepo.storeProducts(products);

                      setState(() {
                        title = "Downloading Categories";
                      });
                      List<CategoryDto> categories = await getCategories();
                      await categoryRepo.storeCategories(categories);

                      setState(() {
                        title = "Downloading Brands";
                      });
                      List<BrandDto> brands = await getBrands();
                      await brandRepo.storeBrands(brands);

                      await configRepo.storeConfigs(ConfigsEntity(
                          id: CommonConstants.catalogueSyncTimeConfigid,
                          key: CommonConstants.catalogueSyncTimeConfigKey,
                          value: DateTime.now().microsecondsSinceEpoch));
                      setState(() {
                        status = DownlaodStatus.success;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        status = DownlaodStatus.failed;
                        title = "Download Failed";
                        subTitle =
                            "Could not download the updated catalogue. Please try again later";
                      });
                    }
                  },
                ),
              ),
            if ((DownlaodStatus.pending == status ||
                    status == DownlaodStatus.failed) &&
                widget.showSkip == true)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 50, right: 50),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CommonCustomColor.warningColor,
                      minimumSize: const Size.fromHeight(40)),
                  child: const Text(
                    "Skip for now",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            if (DownlaodStatus.downloading == status)
              CircularPercentIndicator(
                  radius: 50,
                  lineWidth: 5.0,
                  percent: _percent,
                  backgroundColor: Colors.black12,
                  progressColor: CommonCustomColor.mandelPrimaryColor)
          ],
        ),
        backgroundColor: CommonCustomColor.draftColor.withOpacity(0.95));
  }

  Future<List<ProductDto>> getAllPages() async {
    List<ProductDto> allData = [];
    int page = 0;

    while (true) {
      Response response = await DioClient().dio.get(buildUrl(
          '/product?page=$page&pageSize=1000')); // http.get(Uri.parse('$apiUrl?page=$page'));

      if (response.statusCode == 200) {
        // Parse the response JSON
        // List<dynamic> currentPageData = json.decode(response.body);

        var results = ProductSearchResultDto.fromJson(response.data);

        setState(() {
          totalCount = results.meta!.totalCount!;
        });

        // Add the current page data to the result
        allData.addAll(results.results!);

        // Check if there are more pages
        if (results.meta!.page! >= results.meta!.totalCount! / 1000) {
          break; // No more pages, break out of the loop
        }
        //calculate percent
        double per = ((page * 1000) / results.meta!.totalCount!);
        setState(() {
          _percent = per;
        });
        // Increment page number for the next request
        page++;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    }

    return allData;
  }

  Future<List<CategoryDto>> getCategories() async {
    Response response = await DioClient().dio.get(buildUrl('/category'));
    List<CategoryDto> categoryList = [];
    categoryList.addAll(
        (response.data as List).map((e) => CategoryDto.fromJson(e)).toList());
    return categoryList;
  }

  Future<List<BrandDto>> getBrands() async {
    Response response = await DioClient().dio.get(buildUrl('/brand'));
    List<BrandDto> categoryList = [];
    categoryList.addAll(
        (response.data as List).map((e) => BrandDto.fromJson(e)).toList());
    return categoryList;
  }

  Future<List<SizeDto>> getSize() async {
    Response response = await DioClient().dio.get(buildUrl('/size'));
    List<SizeDto> categoryList = [];
    categoryList.addAll(
        (response.data as List).map((e) => SizeDto.fromJson(e)).toList());
    return categoryList;
  }
}

enum DownlaodStatus { pending, downloading, success, failed }
