import 'package:ip2location/country.dart';
import 'package:test/test.dart';

void main() {
  var countryFile =
      r'C:\your_folder\IP2LOCATION-COUNTRY-INFORMATION\IP2LOCATION-COUNTRY-INFORMATION.CSV';
  group('Test Country CSV', () {
    test('Test US', () async {
      var country = await Country.fromFile(countryFile);
      var countryInfo = country.getCountryInfo('US');
      expect(countryInfo?['country_code'], 'US');
    });
    test('Test All', () async {
      var country = await Country.fromFile(countryFile);
      var countryInfoList = country.getAllCountryInfo();
      expect(
        countryInfoList.any((country) => country['country_code'] == 'US'),
        true,
      );
      expect(
        countryInfoList.any((country) => country['country_code'] == 'AU'),
        true,
      );
    });
  }, skip: 'Skipping Country CSV tests first.');
}
