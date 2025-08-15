import 'dart:io';
import 'dart:typed_data';
import 'constants.dart';
import 'file_utils.dart';
import 'ip_result.dart';
import 'ip_utils.dart';
import 'ipv6_utils.dart';
import 'metadata.dart';
import 'positions.dart';
import 'package:synchronized/synchronized.dart';

/// The field mappings for offsets and whether field is supported.
enum _Fields {
  country,
  region,
  city,
  isp,
  domain,
  zipCode,
  latitude,
  longitude,
  timeZone,
  netSpeed,
  iddCode,
  areaCode,
  weatherStationCode,
  weatherStationName,
  mcc,
  mnc,
  mobileBrand,
  elevation,
  usageType,
  addressType,
  category,
  district,
  asn,
  asName,
}

/// The result field to return or all result fields.
enum _Modes {
  countryShort,
  countryLong,
  region,
  city,
  isp,
  domain,
  zipCode,
  latitude,
  longitude,
  timeZone,
  netSpeed,
  iddCode,
  areaCode,
  weatherStationCode,
  weatherStationName,
  mcc,
  mnc,
  mobileBrand,
  elevation,
  usageType,
  addressType,
  category,
  district,
  asn,
  asName,
  all,
}

/// Queries geolocation data for an IP address by reading the IP2Location BIN file.
///
/// The commercial BIN file can be downloaded from https://www.ip2location.com.
/// The free LITE BIN file can be downloaded from https://lite.ip2location.com.
class IP2Location {
  late final String databasePath;
  late final File _binFile;
  MetaData? _metaData;
  late int _ipv4ColumnSize;
  late int _ipv6ColumnSize;
  final List<List<int>> _indexArrayIPv4 = List.generate(
    65536,
    (_) => List.filled(2, 0),
  );
  final List<List<int>> _indexArrayIPv6 = List.generate(
    65536,
    (_) => List.filled(2, 0),
  );
  final Map<_Fields, int> _offsets = {};
  final Map<_Fields, bool> _enabled = {};
  final _lock = Lock();

  /// Returns the version of the library.
  static String apiVersion() => version;

  /// Returns the IP2Location DB BIN package in use.
  String packageVersion() => _metaData?.dbType.toString() ?? 'unknown';

  /// Returns the IP2Location DB BIN release date.
  String databaseVersion() => _metaData == null
      ? 'unknown'
      : '20${_metaData!.dbYear}.${_metaData!.dbMonth}.${_metaData!.dbDay}';

  /// Sets the field offsets and whether field is supported based on [dbType].
  Future<void> _setOffsetsAndFlags(int dbType) async {
    final mapping = {
      _Fields.country: countryPosition,
      _Fields.region: regionPosition,
      _Fields.city: cityPosition,
      _Fields.isp: ispPosition,
      _Fields.domain: domainPosition,
      _Fields.zipCode: zipCodePosition,
      _Fields.latitude: latitudePosition,
      _Fields.longitude: longitudePosition,
      _Fields.timeZone: timeZonePosition,
      _Fields.netSpeed: netSpeedPosition,
      _Fields.iddCode: iddCodePosition,
      _Fields.areaCode: areaCodePosition,
      _Fields.weatherStationCode: weatherStationCodePosition,
      _Fields.weatherStationName: weatherStationNamePosition,
      _Fields.mcc: mccPosition,
      _Fields.mnc: mncPosition,
      _Fields.mobileBrand: mobileBrandPosition,
      _Fields.elevation: elevationPosition,
      _Fields.usageType: usageTypePosition,
      _Fields.addressType: addressTypePosition,
      _Fields.category: categoryPosition,
      _Fields.district: districtPosition,
      _Fields.asn: asnPosition,
      _Fields.asName: asPosition,
    };
    mapping.forEach((field, positionArray) {
      final pos = positionArray[dbType];
      _offsets[field] = _calcOffset(pos);
      _enabled[field] = pos != 0;
    });
  }

  IP2Location({required this.databasePath}) {
    _binFile = File(databasePath);
  }

  /// Loads the required metadata from the BIN file.
  Future<bool> _loadBin() async {
    return await _lock.synchronized(() async {
      bool loadOK = false;
      RandomAccessFile? file;

      if (_metaData == null || _metaData!.dbType == 0) {
        try {
          if (await _binFile.exists()) {
            file = await _binFile.open();

            // Reads the 64-byte header
            final headerData = Uint8List(64);
            await file.readInto(headerData);
            final headerBuffer = ByteData.sublistView(headerData);

            _metaData = MetaData();

            _metaData!.dbType = headerBuffer.getUint8(0);
            _metaData!.dbColumn = headerBuffer.getUint8(1);
            _metaData!.dbYear = headerBuffer.getUint8(2);
            _metaData!.dbMonth = headerBuffer.getUint8(3);
            _metaData!.dbDay = headerBuffer.getUint8(4);
            _metaData!.dbCount = headerBuffer.getUint32(5, Endian.little);
            _metaData!.baseAddress = headerBuffer.getUint32(9, Endian.little);
            _metaData!.dbCountIPv6 = headerBuffer.getUint32(13, Endian.little);
            _metaData!.baseAddressIPv6 = headerBuffer.getUint32(
              17,
              Endian.little,
            );
            _metaData!.indexBaseAddress = headerBuffer.getUint32(
              21,
              Endian.little,
            );
            _metaData!.indexBaseAddressIPv6 = headerBuffer.getUint32(
              25,
              Endian.little,
            );
            _metaData!.productCode = headerBuffer.getUint8(29);
            _metaData!.productType = headerBuffer.getUint8(30);
            _metaData!.fileSize = headerBuffer.getUint32(31, Endian.little);

            if ((_metaData!.productCode != 1 && _metaData!.dbYear >= 21) ||
                (_metaData!.dbType == 80 && _metaData!.dbColumn == 75)) {
              throw Exception(IPResult.invalidBin);
            }

            if (_metaData!.indexBaseAddress > 0) _metaData!.indexed = true;
            if (_metaData!.dbCountIPv6 == 0) {
              _metaData!.oldBin = true;
            } else if (_metaData!.indexBaseAddressIPv6 > 0) {
              _metaData!.indexedIPv6 = true;
            }

            final dbColumn = _metaData!.dbColumn;
            _ipv4ColumnSize = dbColumn << 2;
            _ipv6ColumnSize = 16 + ((dbColumn - 1) << 2);

            await _setOffsetsAndFlags(_metaData!.dbType);

            if (_metaData!.indexed) {
              var readLen = _indexArrayIPv4.length;
              if (_metaData!.indexedIPv6) readLen += _indexArrayIPv6.length;

              final indexData = Uint8List(readLen * 8);
              await file.setPosition(_metaData!.indexBaseAddress - 1);
              await file.readInto(indexData);
              final indexBuffer = ByteData.sublistView(indexData);

              var pointer = 0;

              for (var i = 0; i < _indexArrayIPv4.length; i++) {
                _indexArrayIPv4[i][0] = indexBuffer.getUint32(
                  pointer,
                  Endian.little,
                );
                _indexArrayIPv4[i][1] = indexBuffer.getUint32(
                  pointer + 4,
                  Endian.little,
                );
                pointer += 8;
              }

              if (_metaData!.indexedIPv6) {
                for (var i = 0; i < _indexArrayIPv6.length; i++) {
                  _indexArrayIPv6[i][0] = indexBuffer.getUint32(
                    pointer,
                    Endian.little,
                  );
                  _indexArrayIPv6[i][1] = indexBuffer.getUint32(
                    pointer + 4,
                    Endian.little,
                  );
                  pointer += 8;
                }
              }
            }

            loadOK = true;
          }
        } finally {
          await file?.close();
        }
      }

      return loadOK;
    });
  }

  int _calcOffset(int pos) => (pos != 0) ? (pos - 2) << 2 : 0;

  Future<IPResult> getAll(String? ipAddress) async {
    return await _query(ipAddress);
  }

  Future<IPResult> getCountryShort(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.countryShort);
  }

  Future<IPResult> getCountryLong(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.countryLong);
  }

  Future<IPResult> getRegion(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.region);
  }

  Future<IPResult> getCity(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.city);
  }

  Future<IPResult> getIsp(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.isp);
  }

  Future<IPResult> getLatitude(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.latitude);
  }

  Future<IPResult> getLongitude(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.longitude);
  }

  Future<IPResult> getDomain(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.domain);
  }

  Future<IPResult> getZipCode(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.zipCode);
  }

  Future<IPResult> getNetSpeed(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.netSpeed);
  }

  Future<IPResult> getTimeZone(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.timeZone);
  }

  Future<IPResult> getIddCode(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.iddCode);
  }

  Future<IPResult> getAreaCode(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.areaCode);
  }

  Future<IPResult> getWeatherStationCode(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.weatherStationCode);
  }

  Future<IPResult> getWeatherStationName(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.weatherStationName);
  }

  Future<IPResult> getMcc(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.mcc);
  }

  Future<IPResult> getMnc(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.mnc);
  }

  Future<IPResult> getMobileBrand(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.mobileBrand);
  }

  Future<IPResult> getElevation(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.elevation);
  }

  Future<IPResult> getUsageType(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.usageType);
  }

  Future<IPResult> getAddressType(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.addressType);
  }

  Future<IPResult> getCategory(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.category);
  }

  Future<IPResult> getDistrict(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.district);
  }

  Future<IPResult> getAsn(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.asn);
  }

  Future<IPResult> getAsName(String? ipAddress) async {
    return await _query(ipAddress, mode: _Modes.asName);
  }

  /// Queries the BIN file based on [ipAddress] and [mode].
  Future<IPResult> _query(String? ipAddress, {_Modes mode = _Modes.all}) async {
    if (ipAddress != null) {
      ipAddress = ipAddress.trim().toUpperCase();
    }
    final record = IPResult(ipAddress ?? "");
    RandomAccessFile? fileHandle;

    try {
      if (ipAddress == null || ipAddress.isEmpty) {
        record.loadMessage(IPResult.invalidAddress);
        return record;
      }

      BigInt ipNo;
      int myIpType;
      int actualIpType;
      int myBaseAddress = 0;
      int myColumnSize;
      BigInt maxIpRange;
      int firstCol = 4; // IPv4 first column size

      // Converts IP to number.
      try {
        final bi = ip2No(
          ipAddress,
        ); // Returns [ipType, ipNumber, actualIpType].
        myIpType = bi[0].toInt();
        ipNo = bi[1];
        actualIpType = bi[2].toInt();

        if (actualIpType == 6) {
          final retArr = expandIPv6(ipAddress, myIpType);
          record.ipAddress = retArr[0].toUpperCase();
          myIpType = int.parse(retArr[1]);
        }
      } catch (_) {
        record.loadMessage(IPResult.invalidAddress);
        return record;
      }

      // Loads BIN if not yet loaded.
      if (_metaData == null || _metaData!.dbType == 0) {
        if (!await _loadBin()) {
          record.loadMessage(IPResult.missingFile);
          return record;
        }
      }

      fileHandle = await _binFile.open();

      late List<List<int>> indexArray;
      if (myIpType == 4) {
        maxIpRange = maxIPv4Range;
        myBaseAddress = _metaData!.baseAddress;
        myColumnSize = _ipv4ColumnSize;
        indexArray = _indexArrayIPv4;
      } else {
        firstCol = 16;
        if (_metaData!.oldBin) {
          record.loadMessage(IPResult.ipv6NotSupported);
          return record;
        }
        maxIpRange = maxIPv6Range;
        myBaseAddress = _metaData!.baseAddressIPv6;
        myColumnSize = _ipv6ColumnSize;
        indexArray = _indexArrayIPv6;
      }

      if (ipNo == maxIpRange) {
        ipNo -= BigInt.one;
      }

      var low = BigInt.zero;
      var high = BigInt.from(
        myIpType == 4 ? _metaData!.dbCount : _metaData!.dbCountIPv6,
      );

      // Refers to index for optimized lookup.
      if (myIpType == 4 && _metaData!.indexed) {
        final indexAddress = ipNo >> 16;
        low = BigInt.from(indexArray[indexAddress.toInt()][0]);
        high = BigInt.from(indexArray[indexAddress.toInt()][1]);
      } else if (myIpType == 6 && _metaData!.indexedIPv6) {
        final indexAddress = ipNo >> 112;
        low = BigInt.from(indexArray[indexAddress.toInt()][0]);
        high = BigInt.from(indexArray[indexAddress.toInt()][1]);
      }

      while (low <= high) {
        final mid = (low + high) >> 1;
        final rowOffset = myBaseAddress + (mid.toInt() * myColumnSize);

        // Reads a full row of data for a contiguous range of IP addresses.
        final fullRow = await readRow(
          position: rowOffset,
          length: myColumnSize + firstCol,
          file: fileHandle,
        );
        final ipFrom = read32or128Row(fullRow, 0, firstCol);
        final ipTo = read32or128Row(fullRow, myColumnSize, firstCol);

        if (ipNo >= ipFrom && ipNo < ipTo) {
          final row = fullRow.sublist(firstCol);

          record.countryShort =
              _enabled[_Fields.country]! &&
                  (mode == _Modes.all || mode == _Modes.countryShort)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.country]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.countryLong =
              _enabled[_Fields.country]! &&
                  (mode == _Modes.all || mode == _Modes.countryLong)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.country]!) + 3,
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.region =
              _enabled[_Fields.region]! &&
                  (mode == _Modes.all || mode == _Modes.region)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.region]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.city =
              _enabled[_Fields.city]! &&
                  (mode == _Modes.all || mode == _Modes.city)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.city]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.isp =
              _enabled[_Fields.isp]! &&
                  (mode == _Modes.all || mode == _Modes.isp)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.isp]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.latitude =
              _enabled[_Fields.latitude]! &&
                  (mode == _Modes.all || mode == _Modes.latitude)
              ? readFloatRow(row, _offsets[_Fields.latitude]!)
              : 0.0;
          record.longitude =
              _enabled[_Fields.longitude]! &&
                  (mode == _Modes.all || mode == _Modes.longitude)
              ? readFloatRow(row, _offsets[_Fields.longitude]!)
              : 0.0;
          record.domain =
              _enabled[_Fields.domain]! &&
                  (mode == _Modes.all || mode == _Modes.domain)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.domain]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.zipCode =
              _enabled[_Fields.zipCode]! &&
                  (mode == _Modes.all || mode == _Modes.zipCode)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.zipCode]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.timeZone =
              _enabled[_Fields.timeZone]! &&
                  (mode == _Modes.all || mode == _Modes.timeZone)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.timeZone]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.netSpeed =
              _enabled[_Fields.netSpeed]! &&
                  (mode == _Modes.all || mode == _Modes.netSpeed)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.netSpeed]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.iddCode =
              _enabled[_Fields.iddCode]! &&
                  (mode == _Modes.all || mode == _Modes.iddCode)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.iddCode]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.areaCode =
              _enabled[_Fields.areaCode]! &&
                  (mode == _Modes.all || mode == _Modes.areaCode)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.areaCode]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.weatherStationCode =
              _enabled[_Fields.weatherStationCode]! &&
                  (mode == _Modes.all || mode == _Modes.weatherStationCode)
              ? await readStr(
                  position: read32Row(
                    row,
                    _offsets[_Fields.weatherStationCode]!,
                  ),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.weatherStationName =
              _enabled[_Fields.weatherStationName]! &&
                  (mode == _Modes.all || mode == _Modes.weatherStationName)
              ? await readStr(
                  position: read32Row(
                    row,
                    _offsets[_Fields.weatherStationName]!,
                  ),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.mcc =
              _enabled[_Fields.mcc]! &&
                  (mode == _Modes.all || mode == _Modes.mcc)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.mcc]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.mnc =
              _enabled[_Fields.mnc]! &&
                  (mode == _Modes.all || mode == _Modes.mnc)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.mnc]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.mobileBrand =
              _enabled[_Fields.mobileBrand]! &&
                  (mode == _Modes.all || mode == _Modes.mobileBrand)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.mobileBrand]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.elevation =
              _enabled[_Fields.elevation]! &&
                  (mode == _Modes.all || mode == _Modes.elevation)
              ? parseFloat32(
                  await readStr(
                        position: read32Row(row, _offsets[_Fields.elevation]!),
                        file: fileHandle,
                      ) ??
                      "0",
                )
              : 0.0;
          record.usageType =
              _enabled[_Fields.usageType]! &&
                  (mode == _Modes.all || mode == _Modes.usageType)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.usageType]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.addressType =
              _enabled[_Fields.addressType]! &&
                  (mode == _Modes.all || mode == _Modes.addressType)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.addressType]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.category =
              _enabled[_Fields.category]! &&
                  (mode == _Modes.all || mode == _Modes.category)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.category]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.district =
              _enabled[_Fields.district]! &&
                  (mode == _Modes.all || mode == _Modes.district)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.district]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.asn =
              _enabled[_Fields.asn]! &&
                  (mode == _Modes.all || mode == _Modes.asn)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.asn]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;
          record.asName =
              _enabled[_Fields.asName]! &&
                  (mode == _Modes.all || mode == _Modes.asName)
              ? await readStr(
                  position: read32Row(row, _offsets[_Fields.asName]!),
                  file: fileHandle,
                )
              : IPResult.notSupported;

          return record;
        } else {
          if (ipNo < ipFrom) {
            high = mid - BigInt.one;
          } else {
            low = mid + BigInt.one;
          }
        }
      }

      record.loadMessage(IPResult.invalidAddress);
      return record;
    } finally {
      await fileHandle?.close();
    }
  }
}
