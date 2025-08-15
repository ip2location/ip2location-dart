import 'dart:io';
import 'package:csv/csv.dart';

/// Parses the IP2Location ISO 3166-2 Subdivision Code CSV file and returns the region code.
///
/// This file is free for download at https://www.ip2location.com/free/iso3166-2.
class Region {
  final Map<String, List<Map<String, String>>> _records = {};

  /// Creates a [Region] instance by reading and parsing a CSV file.
  ///
  /// The [csvFile] parameter is the full path to the region information CSV file.
  static Future<Region> fromFile(String csvFile) async {
    final region = Region._();

    final file = File(csvFile);
    if (!await file.exists()) {
      throw Exception('The CSV file $csvFile is not found.');
    }

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      throw Exception('Unable to read $csvFile.');
    }

    // Auto-detects EOL.
    final rows = const CsvToListConverter().convert(contents);

    if (rows.isEmpty) {
      throw Exception('Invalid region information CSV file.');
    }

    final headers = rows.first.map((h) => h.toString()).toList();
    final subdivisionNameIndex = headers.indexOf("subdivision_name");
    final countryCodeIndex = headers.indexOf("country_code");
    final codeIndex = headers.indexOf("code");

    if (subdivisionNameIndex == -1 ||
        countryCodeIndex == -1 ||
        codeIndex == -1) {
      throw Exception('Invalid region information CSV file.');
    }

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];

      final subdivisionName = row[subdivisionNameIndex]?.toString() ?? '';
      final countryCode = row[countryCodeIndex]?.toString() ?? '';
      final code = row[codeIndex]?.toString() ?? '';

      if (countryCode.isEmpty || subdivisionName.isEmpty) {
        continue; // skip bad rows
      }

      region._records.putIfAbsent(countryCode, () => []);

      region._records[countryCode]!.add({subdivisionName.toUpperCase(): code});
    }

    return region;
  }

  Region._(); // private constructor

  /// Returns the region code for the supplied [countryCode] and [regionName].
  String? getRegionCode(String countryCode, String regionName) {
    if (_records.isEmpty) {
      throw Exception('No record available.');
    }

    final items = _records[countryCode];
    if (items == null) return null;

    final region = regionName.toUpperCase();
    for (final item in items) {
      final regionCode = item[region];
      if (regionCode != null) return regionCode;
    }

    return null;
  }
}
