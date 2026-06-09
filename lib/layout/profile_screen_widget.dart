import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/db/repository/order_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/order_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_item_repository.dart';
import 'package:mandel_mobile_app/db/repository/return_master_repository.dart';
import 'package:mandel_mobile_app/db/repository/user_master_repository.dart';
import 'package:mandel_mobile_app/layout/main_screen_widget.dart';
import 'package:mandel_mobile_app/model/profile_item_dto.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:mandel_mobile_app/utility/common_custom_color.dart';
import 'package:mandel_mobile_app/utility/profile_clip_path.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreenWidget extends StatefulWidget {
  final bool isFromHomePage;

  const ProfileScreenWidget({required this.isFromHomePage, super.key});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget>
    with AuthSupportUtility {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [_build(), ..._buildProfileOptionList()],
      ),
    );
  }

  Widget _build() {
    return Stack(
      children: [_buildClipPath(), _buildClipPathOverlay()],
    );
  }

  ///This method can be used for build clip path
  Widget _buildClipPath() {
    return ClipPath(
      clipper: ProfileClipPath(),
      child: Container(
        width: double.infinity,
        height: 310,
        color: CommonCustomColor.mandelPrimaryColor,
      ),
    );
  }

  ///This method can be used for build clip path overlay
  Widget _buildClipPathOverlay() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 50),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildUserInformation()],
      ),
    );
  }

  ///This method can be used for build profile image and profile image selection
  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          height: 130.0,
          width: 130.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.amber,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 100, top: 80),
          height: 31.0,
          width: 31.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 17,
            ),
            onPressed: () {},
          ),
        )
      ],
    );
  }

  ///This method can be used for build user information
  Widget _buildUserInformation() {
    return Padding(
      padding: const EdgeInsets.only(left: 23, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back,',
              style: TextStyle(fontSize: 20, color: Colors.white)),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 15),
            child: FutureBuilder(
              future: UserMasterRepository().getUserName(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  );
                }
                return const Text('Pending');
              },
            ),
          ),
          // SizedBox(
          //   width: 135,
          //   height: 42,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //         backgroundColor: const Color(0xFFFF9D0A),
          //         shape: const RoundedRectangleBorder(
          //           borderRadius: BorderRadius.all(Radius.circular(15.0)),
          //         ),
          //         minimumSize: const Size.fromHeight(45)),
          //     onPressed: () {},
          //     child: const Text(
          //       "Edit Profile",
          //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  ///This method can be used for build profile item list
  List<Widget> _buildProfileOptionList() {
    List<ProfileItemDto> itemList = <ProfileItemDto>[
      ProfileItemDto(
        index: 0,
        icon: Icons.list_outlined,
        itemName: 'My Orders',
      ),
      ProfileItemDto(
        index: 1,
        icon: Icons.shopping_cart,
        itemName: 'My Cart',
      ),
      ProfileItemDto(
        index: 2,
        icon: Icons.help_outline,
        itemName: 'Get Help',
      ),
      ProfileItemDto(
        index: 4,
        icon: Icons.exit_to_app_outlined,
        itemName: 'Logout',
        iconColor: CommonCustomColor.warningColor,
      )
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

  ///This method can be used for navigate to item selections
  _manageItemSelection(int key) async {
    if (key == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return const MainScreenWidget(
            defaultIndex: 1,
          );
        },
      ), (route) => false);
    }
    if (key == 1) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return const MainScreenWidget(
            defaultIndex: 2,
          );
        },
      ), (route) => false);
    }
    if (key == 2) {
      final Uri url = Uri.parse(CommonConstants.helpUrl);
      await launchUrl(url);
    }

    if (key == 4) {
      signOutUser();
      UserMasterRepository().clearUserMaster();
      OrderRepository().clearOrderItems();
      OrderMasterRepository().clearOrderMaster();
      ReturnItemRepository().clearReturnItems();
      ReturnMasterRepository().clearReturnMaster();
      Navigator.pushNamedAndRemoveUntil(
          context, CommonConstants.loginScreenUrl, (route) => false);
    }
  }
}
