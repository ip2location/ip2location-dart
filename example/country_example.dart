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
