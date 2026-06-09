import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductListHistoryWidget extends StatefulWidget {
  ///
  final Function(String searchText) onSelectHistory;

  const ProductListHistoryWidget({super.key, required this.onSelectHistory});

  @override
  State<ProductListHistoryWidget> createState() =>
      _ProductListHistoryWidgetState();
}

class _ProductListHistoryWidgetState extends State<ProductListHistoryWidget> {
  ///
  ///
  Future<List<String>> _getSearchResults() async {
    final localStorage = await SharedPreferences.getInstance();

    List<String>? items =
        localStorage.getStringList(CommonConstants.itemFilterHistoryList);
    items ??= [];

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecentSearchesTitle(),
            _buildRecentSearchesResults()
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesTitle() {
    return const Text(
      'Recent Searches',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildRecentSearchesResults() {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.displayMedium!,
      textAlign: TextAlign.center,
      child: FutureBuilder<List<String>>(
        future: _getSearchResults(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          List<Widget> children = [];

          if (snapshot.hasData) {
            for (var element in snapshot.data!) {
              children.add(Container(
                margin: const EdgeInsets.only(right: 10, top: 10),
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.restore_outlined,
                    size: 24.0,
                  ),
                  onPressed: () {
                    widget.onSelectHistory(element);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: CommonCustomColor.defaultTextColor,
                    backgroundColor: CommonCustomColor.filterButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  label: Text(element.toString()),
                ),
              ));
            }
          } else {
            children = const <Widget>[
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
              )
            ];
          }

          return Wrap(
            direction: Axis.horizontal,
            children: children,
          );
        },
      ),
    );
  }
}
