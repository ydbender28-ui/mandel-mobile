import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/category_product_screen_widget.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/service/category_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shimmer/shimmer.dart';

const Map<String, IconData> _kCatIcons = {
  'Cigarettes':          Icons.smoking_rooms_rounded,
  'E-Cigarettes':        Icons.cloud_rounded,
  'Tobacco':             Icons.grass_rounded,
  'Tobacco Accessories': Icons.stars_rounded,
  'Rolling Papers':      Icons.article_rounded,
  'Candy & Snacks':      Icons.fastfood_rounded,
  'Chocolate':           Icons.cookie_rounded,
  'Drinks':              Icons.local_drink_rounded,
  'Grocery':             Icons.shopping_basket_rounded,
  'Refrigerated':        Icons.kitchen_rounded,
  'Frozen':              Icons.ac_unit_rounded,
  'Health & Beauty':     Icons.health_and_safety_rounded,
  'Pet Food':            Icons.pets_rounded,
  'Kratom':              Icons.eco_rounded,
  'Automotive':          Icons.directions_car_rounded,
  'Toys':                Icons.toys_rounded,
  'THCA':                Icons.bolt_rounded,
  'Adult Pills':         Icons.medication_rounded,
  'Misc':                Icons.category_rounded,
};

const Map<String, Color> _kCatColors = {
  'Cigarettes':          Color(0xFF7C3AED),
  'E-Cigarettes':        Color(0xFF0284C7),
  'Tobacco':             Color(0xFF4C1D95),
  'Tobacco Accessories': Color(0xFF4F46E5),
  'Rolling Papers':      Color(0xFF64748B),
  'Candy & Snacks':      Color(0xFFEC4899),
  'Chocolate':           Color(0xFF92400E),
  'Drinks':              Color(0xFF0EA5E9),
  'Grocery':             Color(0xFF10B981),
  'Refrigerated':        Color(0xFF06B6D4),
  'Frozen':              Color(0xFF3730A3),
  'Health & Beauty':     Color(0xFF22C55E),
  'Pet Food':            Color(0xFFD97706),
  'Kratom':              Color(0xFF16A34A),
  'Automotive':          Color(0xFF475569),
  'Toys':                Color(0xFFF59E0B),
  'THCA':                Color(0xFF0D9488),
  'Adult Pills':         Color(0xFFE879F9),
  'Misc':                Color(0xFF6366F1),
};

Color _catColorFallback(int index) {
  const palette = [
    Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFFF59E0B),
    Color(0xFF10B981), Color(0xFFEC4899), Color(0xFFEF4444),
    Color(0xFF8B5CF6), Color(0xFF14B8A6), Color(0xFFD97706),
    Color(0xFF22C55E), Color(0xFF0284C7), Color(0xFFDB2777),
  ];
  return palette[index % palette.length];
}

class CategoryScreenWidget extends StatefulWidget {
  const CategoryScreenWidget({super.key});

  @override
  State<CategoryScreenWidget> createState() => _CategoryScreenWidgetState();
}

class _CategoryScreenWidgetState extends State<CategoryScreenWidget> {
  ///
  final _categoryService = CategoryService();

  ///
  final _searchFieldController = TextEditingController();

  ///
  Map<String, dynamic>? filters = <String, dynamic>{};

  ///
  var status = 1;

  Future<List<CategoryDto>> _loadCategoryList() async {
    // Response response = await _categoryService.getCategoryList(filters);
    // List<CategoryDto> categoryList = (response.data as List)
    //     .map((data) => CategoryDto.fromJson(data))
    //     .toList();
    // return categoryList;
    return _categoryService.getAllCategoryList(filters);
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
      backgroundColor: const Color(0xFFF0F2FA),
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
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C0F1E), Color(0xFF1B2860)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: const Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterField() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: TextFormField(
        controller: _searchFieldController,
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty) {
              filters!['name'] = value;
            } else {
              filters!.remove('name');
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search categories…',
          hintStyle: const TextStyle(color: Color(0xFF9AA3C2), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9AA3C2)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _searchFieldController.text.isNotEmpty
            ? IconButton(
                onPressed: () => setState(() { _searchFieldController.clear(); filters!.remove('name'); }),
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF9AA3C2)))
            : null,
        ),
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
      future: _loadCategoryList(),
      builder: (BuildContext context, AsyncSnapshot<List<CategoryDto>> result) {
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
      future: _loadCategoryList(),
      builder: (BuildContext context, AsyncSnapshot<List<CategoryDto>> result) {
        if (result.connectionState == ConnectionState.done && result.hasData) {
          return Expanded(
            child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                itemCount: result.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 0.88,
                    crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemBuilder: (_, index) {
                  final cat = result.data![index];
                  final name = cat.name ?? '';
                  final icon = _kCatIcons[name] ?? Icons.category_rounded;
                  final color = _kCatColors[name] ?? _catColorFallback(index);
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CategoryProductScreenWidget(categoryDto: cat))),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.22)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              shape: BoxShape.circle),
                            child: Icon(icon, color: color, size: 26),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: color, height: 1.2)),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildListItems(BuildContext context, CategoryDto categoryDto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: _buildImageView(categoryDto),
        title: Text(
          categoryDto.name ?? CommonConstants.emptyRecodeIndicator,
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
                    CategoryProductScreenWidget(categoryDto: categoryDto)),
          );
        },
      ),
    );
  }

  Widget _buildImageView(CategoryDto categoryDto) {
    final name = categoryDto.name ?? '';
    final icon = _kCatIcons[name] ?? Icons.category_rounded;
    final colorIdx = (categoryDto.id ?? 0) % 12;
    final color = _kCatColors[name] ?? _catColorFallback(colorIdx);
    return Container(
      width: 52, height: 52,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 26),
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
