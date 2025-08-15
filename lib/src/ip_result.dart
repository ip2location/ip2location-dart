/// Stores the geolocation results.
class IPResult {
  static const String invalidAddress = 'Invalid IP address.';
  static const String missingFile = 'Invalid database file.';
  static const String notSupported =
      'This parameter is unavailable for selected data file. Please upgrade the data file.';
  static const String invalidBin =
      'Incorrect IP2Location BIN file format. Please make sure that you are using the latest IP2Location BIN file.';
  static const String ipv6NotSupported = 'IPv6 address missing in IPv4 BIN.';

  late String ipAddress;
  String? countryShort;
  String? countryLong;
  String? region;
  String? city;
  String? isp;
  double? latitude;
  double? longitude;
  String? domain;
  String? zipCode;
  String? netSpeed;
  String? timeZone;
  String? iddCode;
  String? areaCode;
  String? weatherStationCode;
  String? weatherStationName;
  String? mcc;
  String? mnc;
  String? mobileBrand;
  double? elevation;
  String? usageType;
  String? addressType;
  String? category;
  String? district;
  String? asn;
  String? asName;

  IPResult(this.ipAddress);

  /// Loads all String fields with error [message].
  void loadMessage(String message) {
    countryShort = message;
    countryLong = message;
    region = message;
    city = message;
    isp = message;
    domain = message;
    zipCode = message;
    netSpeed = message;
    timeZone = message;
    iddCode = message;
    areaCode = message;
    weatherStationCode = message;
    weatherStationName = message;
    mcc = message;
    mnc = message;
    mobileBrand = message;
    usageType = message;
    addressType = message;
    category = message;
    district = message;
    asn = message;
    asName = message;
  }

  @override
  String toString() {
    return '''
IPResult(
  ipAddress: $ipAddress,
  countryShort: $countryShort,
  countryLong: $countryLong,
  region: $region,
  city: $city,
  isp: $isp,
  latitude: $latitude,
  longitude: $longitude,
  domain: $domain,
  zipCode: $zipCode,
  netSpeed: $netSpeed,
  timeZone: $timeZone,
  iddCode: $iddCode,
  areaCode: $areaCode,
  weatherStationCode: $weatherStationCode,
  weatherStationName: $weatherStationName,
  mcc: $mcc,
  mnc: $mnc,
  mobileBrand: $mobileBrand,
  elevation: $elevation,
  usageType: $usageType,
  addressType: $addressType,
  category: $category,
  district: $district,
  asn: $asn,
  asName: $asName
)''';
  }
}
