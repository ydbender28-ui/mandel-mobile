import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/repository/configs_repository.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/multi_action_confirmation_widget.dart';
import 'package:mandel_mobile_app/layout/product_sync.dart';
import 'package:mandel_mobile_app/model/profile_item_dto.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class SettingsScreenWidget extends StatefulWidget {
  const SettingsScreenWidget({super.key});

  @override
  State<SettingsScreenWidget> createState() => _SettingsScreenWidgetState();
}

class _SettingsScreenWidgetState extends State<SettingsScreenWidget> {
  final ConfigsRepository _configsRepository = ConfigsRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _buildBackButton(),
        title: _buildTitle(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Image.asset(
        'assets/images/mandel_angle_left.png',
        width: 25,
        height: 24,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  _buildTitle() {
    return const Text(
      'Settings',
      style: TextStyle(fontSize: 24),
    );
  }

  _buildBody() {
    return Column(
      children: [..._buildListItems()],
    );
  }

  _buildListItems() {
    List<ProfileItemDto> itemList = <ProfileItemDto>[
      ProfileItemDto(
        index: 0,
        icon: Icons.bluetooth,
        itemName: 'Linked Devices',
      ),
      ProfileItemDto(
        index: 1,
        icon: Icons.qr_code_scanner,
        itemName: 'Default Scanner',
      ),
      ProfileItemDto(
        index: 2,
        icon: Icons.sync,
        itemName: 'Update Catalogue',
      ),
    ];

    List<Widget> options = [];

    for (var element in itemList) {
      options.add(InkWell(
        onTap: () {
          _manageItemSelection(element.index);
        },
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 0.5,
          ))),
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: Icon(
                    element.icon,
                    color: element.iconColor,
                    size: 24,
                  )),
              Text(
                element.itemName,
                style: TextStyle(fontSize: 18, color: element.textColor),
              ),
              const Spacer(flex: 1),
              Icon(
                Icons.chevron_right_outlined,
                color: element.textColor,
                size: 24,
              ),
            ],
          ),
        ),
      ));
    }

    return options;
  }

  void _manageItemSelection(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, CommonConstants.bluetoothDeviceManagement);
        break;
      case 1:
        _displayDefaultScannerOption();
        break;
      case 2:
        Navigator.of(context).push(PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) => const ProductSync(
                  showSkip: true,
                )));
    }
  }

  void _displayDefaultScannerOption() {
    final List<ConfirmationAction> actions = [
      ConfirmationAction(
          text: "Bluetooth Scanner",
          onSelect: () async {
            Navigator.pop(context);
            await _configsRepository.storeConfigs(ConfigsEntity(
                id: CommonConstants.defaultBarcodeScannerConfigId,
                key: CommonConstants.defaultBarcodeScannerConfigKey,
                value: CommonConstants.bluetoothScanner));
          }),
      ConfirmationAction(
          text: "Camera Scanner",
          onSelect: () async {
            Navigator.pop(context);
            await _configsRepository.storeConfigs(ConfigsEntity(
                id: CommonConstants.defaultBarcodeScannerConfigId,
                key: CommonConstants.defaultBarcodeScannerConfigKey,
                value: CommonConstants.cammeraScanner));
          })
    ];

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return MultiActionConfirmationWidget(
                title: "Select Default Scanner Type", actions: actions);
          });
        });
  }
}
