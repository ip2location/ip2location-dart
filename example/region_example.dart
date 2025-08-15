import 'package:ip2location/region.dart';

Future<void> main() async {
  Region region = await Region.fromFile(
    r'C:\your_folder\IP2LOCATION-ISO3166-2.CSV',
  );
  var regionCode = region.getRegionCode('US', 'California');
  print('Region Code: $regionCode');
}
