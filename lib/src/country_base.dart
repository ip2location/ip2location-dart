import 'dart:io' show File;
import 'package:csv/csv.dart' show CsvToListConverter;

/// Reads the IP2Location Country Information CSV file and returns the country information.
///
/// This file is free for download at https://www.ip2location.com/free/country-information.
class Country {
  final Map<String, Map<String, String>> _records = {};

  /// Creates a [Country] instance by reading and parsing a CSV file.
  ///
  /// The [csvFile] parameter is the full path to the country information CSV file.
  static Future<Country> fromFile(String csvFile) async {
    final country = Country._();

    final file = File(csvFile);
    if (!await file.exists()) {
      throw Exception('The CSV file $csvFile is not found.');
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      throw Exception('Unable to read $csvFile.');
    }

    final rows = const CsvToListConverter().convert(contents);

    if (rows.isEmpty) {
      throw Exception('Invalid country information CSV file.');
    }

    // First row should be headers
    final headers = rows.first.map((h) => h.toString()).toList();
    final countryCodeIndex = headers.indexOf('country_code');

    if (countryCodeIndex == -1) {
      throw Exception('Invalid country information CSV file.');
    }

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final rowMap = <String, String>{};

      for (var j = 0; j < headers.length; j++) {
        rowMap[headers[j]] = row[j]?.toString() ?? '';
      }

      country._records[rowMap['country_code'] ?? ''] = rowMap;
    }

    return country;
  }

  Country._(); // private constructor

  /// Gets the country information for the supplied country code.
  ///
  /// The [countryCode] param is the ISO-3166 country code.
  /// Returns a `Map<String, String>` if found.
  Map<String, String>? getCountryInfo(String countryCode) {
    if (_records.isEmpty) {
      throw Exception('No record available.');
    }
    return _records[countryCode];
  }

  /// Gets the country information for all countries.
  ///
  /// Returns a `List<Map<String, String>>`.
  List<Map<String, String>> getAllCountryInfo() {
    if (_records.isEmpty) {
      throw Exception('No record available.');
    }
    return _records.values.toList();
  }
}
