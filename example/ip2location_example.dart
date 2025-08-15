import 'package:ip2location/ip2location.dart';
import 'package:ip2location/src/ip_result.dart';

Future<void> main() async {
  var dbFile =
      r'C:\your_folder\IPV6-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-ZIPCODE-TIMEZONE-ISP-DOMAIN-NETSPEED-AREACODE-WEATHER-MOBILE-ELEVATION-USAGETYPE-ADDRESSTYPE-CATEGORY-DISTRICT-ASN.BIN';
  IP2Location ipl = IP2Location(databasePath: dbFile);
  var ip = '8.8.8.8';

  IPResult result = await ipl.getAll(ip);

  print('version: ${IP2Location.apiVersion()}');
  print('packageVersion: ${ipl.packageVersion()}');
  print('databaseVersion: ${ipl.databaseVersion()}');
  print('ipAddress: ${result.ipAddress}');
  print('countryShort: ${result.countryShort}');
  print('countryLong: ${result.countryLong}');
  print('region: ${result.region}');
  print('city: ${result.city}');
  print('isp: ${result.isp}');
  print('latitude: ${result.latitude?.toStringAsFixed(6)}');
  print('longitude: ${result.longitude?.toStringAsFixed(6)}');
  print('domain: ${result.domain}');
  print('zipCode: ${result.zipCode}');
  print('netSpeed: ${result.netSpeed}');
  print('timeZone: ${result.timeZone}');
  print('iddCode: ${result.iddCode}');
  print('areaCode: ${result.areaCode}');
  print('weatherStationCode: ${result.weatherStationCode}');
  print('weatherStationName: ${result.weatherStationName}');
  print('mcc: ${result.mcc}');
  print('mnc: ${result.mnc}');
  print('mobileBrand: ${result.mobileBrand}');
  print('elevation: ${result.elevation}');
  print('usageType: ${result.usageType}');
  print('addressType: ${result.addressType}');
  print('category: ${result.category}');
  print('district: ${result.district}');
  print('asn: ${result.asn}');
  print('asName: ${result.asName}');
}
