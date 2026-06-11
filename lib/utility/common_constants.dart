class CommonConstants {
  static const String mandelBaseUrl = 'https://app.mandelwholesale.com/portal/api';
  static const String mandelImageBaseUrl = '';
  static const String helpUrl =
      "https://mandeldelivery.myshopify.com/pages/contact";

  static const String baseUrl = '/';
  static const String offersScreenUrl = '/OffersScreenWidget';
  static const String loginScreenUrl = '/LoginScreenWidget';
  static const String configurationScreenUrl = '/ConfigurationWaitScreenWidget';
  static const String mainScreenUrl = '/MainScreenWidget';
  static const String homeScreenUrl = '/HomeScreenWidget';
  static const String searchScreenUrl = '/SearchScreenWidget';
  static const String brandScreenWidget = '/BrandScreenWidget';
  static const String categoryScreenWidget = '/CategoryScreenWidget';
  static const String productScannerScreenUrl = '/ProductScannerWidget';
  static const String cameraBrcodeScannerUrl = '/CameraBarcodeScanner';
  static const String bluetoothDeviceManagement = '/BluetoothDeviceManagement';
  static const String settingsScreenWidget = '/SettingsScreenWidget';
  static const String returnCartScreenWidget = "/ReturnCartWidget";
  static const String returnListWidget = "/ReturnList";
  static const String dealsListScreenWidget = "/DealsListWidget";
  static const String newsScreenWidget = "/News";
  static const String invoiceScreenWidget = "/Invoice";
  static const String arScreenWidget = "/AR";

  static const String symbolEmptyString = "";
  static const String emptyRecodeIndicator = " - ";

  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';

  ///
  ///Shared Preference key list
  static const String itemFilterHistoryList = 'ITEM_FILTER_HISTORY_LIST';

  ///
  ///Status
  static const String statusAll = 'ALL';
  static const String statusComplete = 'COMPLETE';
  static const String statusPending = 'PENDING';
  static const String statusApprove = 'APPROVED';
  static const String statusDecline = 'DECLINE';
  static const String statusReceived = 'RECEIVED';

  ///
  ///Date Format
  static const String usDateFormat = 'MM-dd-yyyy';

  //Configs
  static const String bluetoothScanerConfigKey = "BLUETOOTH_SCANNER_ID";
  static const int bluetoothScannerConfigid = 1;
  static const String catalogueSyncTimeConfigKey = "LAST_CATALOGUE_SYNC";
  static const int catalogueSyncTimeConfigid = 2;
  static const String defaultBarcodeScannerConfigKey =
      "DEFAULT_BARCODE_SCANNER";
  static const int defaultBarcodeScannerConfigId = 3;
  static const String cammeraScanner = "CAMERA_SCANNER";
  static const String bluetoothScanner = "BLUETOOTH_SCANNER";
}
