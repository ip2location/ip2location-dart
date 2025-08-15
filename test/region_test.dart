import 'package:ip2location/region.dart';
import 'package:test/test.dart';

void main() {
  var regionFile = r'C:\your_folder\IP2LOCATION-ISO3166-2.CSV';
  group('Test Region CSV', () {
    test('Test US Mountain View', () async {
      var region = await Region.fromFile(regionFile);
      var regionCode = region.getRegionCode('US', 'California');
      expect(regionCode, 'US-CA');
    });
  }, skip: 'Skipping Region CSV tests first.');
}
