# Quickstart

## Dependencies

This package requires the IP2Location BIN database to function. You may download the BIN database at

-   IP2Location LITE BIN Data (Free): <https://lite.ip2location.com>
-   IP2Location Commercial BIN Data (Comprehensive):
    <https://www.ip2location.com>

## IPv4 BIN vs IPv6 BIN

Use the IPv4 BIN file if you just need to query IPv4 addresses.

Use the IPv6 BIN file if you need to query BOTH IPv4 and IPv6 addresses.

## Installation

```bash
dart pub add ip2location
```

## Sample Codes

### Query geolocation information from BIN database

You can query the geolocation information from the IP2Location BIN database as below:

```dart
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
```

### Processing IP address using IP Tools class

You can manupulate IP address, IP number and CIDR as below:

```dart
import 'package:ip2location/iptools.dart';

void main() {
  var ip = '8.8.8.8';
  print(IPTools.isIPv4(ip));

  ip = '175.144.140.232';
  print(IPTools.ipv4ToDecimal(ip));

  ip = '2600:1f18:45b0:5b00:f5d8:4183:7710:ceec';
  print(IPTools.isIPv6(ip));

  ip = '2600:1f18:45b0:5b00:f5d8:4183:7710:ceec';
  print(IPTools.ipv6ToDecimal(ip));

  var ipNum = 2945486056;
  print(IPTools.decimalToIPv4(BigInt.from(ipNum)));

  var ipNumStr = '22398978840339333967292465152';
  print(IPTools.decimalToIPv6(BigInt.parse(ipNumStr)));

  ip = '2600:1f18:045b:005b:f5d8:0:000:ceec';
  print(IPTools.compressIPv6(ip));

  ip = '::45b:05b:f5d8:0:000:ceec';
  print(IPTools.expandIPv6(ip));

  var ipFrom = '10.0.0.0';
  var ipTo = '10.10.2.255';
  print(IPTools.ipv4ToCidr(ipFrom, ipTo));

  ipFrom = '2001:4860:4860:0000:0000:0000:0000:8888';
  ipTo = '2001:4860:4860:0000:eeee:ffff:ffff:ffff';
  print(IPTools.ipv6ToCidr(ipFrom, ipTo));

  var cidr = '123.245.99.13/26';
  print(IPTools.cidrToIPv4(cidr));

  cidr = '2002:1234::abcd:ffff:c0a8:101/62';
  print(IPTools.cidrToIPv6(cidr));
}
```

### List down country information

You can query country information for a country from IP2Location Country Information CSV file as below:

```dart
import 'package:ip2location/country.dart';

Future<void> main() async {
  Country country = await Country.fromFile(
    r'C:\your_folder\IP2LOCATION-COUNTRY-INFORMATION.CSV',
  );
  Map<String, String>? countryInfo = country.getCountryInfo('US');

  for (MapEntry<String, String> item in countryInfo!.entries) {
    print('${item.key.toString()} : ${item.value.toString()}');
  }
}
```

### List down region information

You can get the region code by country code and region name from IP2Location ISO 3166-2 Subdivision Code CSV file as below:

```dart
import 'package:ip2location/region.dart';

Future<void> main() async {
  Region region = await Region.fromFile(
    r'C:\your_folder\IP2LOCATION-ISO3166-2.CSV',
  );
  var regionCode = region.getRegionCode('US', 'California');
  print('Region Code: $regionCode');
}
```