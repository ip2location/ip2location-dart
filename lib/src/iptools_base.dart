import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class IPTools {
  static final BigInt maxIPv4Range = BigInt.parse('4294967295');
  static final BigInt maxIPv6Range = BigInt.parse(
    '340282366920938463463374607431768211455',
  );

  static final RegExp binPatternFull = RegExp(r'^([01]{8}){16}$');
  static final RegExp binPattern = RegExp(r'([01]{8})');
  static final RegExp prefixPattern = RegExp(r'^[0-9]{1,2}$');
  static final RegExp prefixPattern2 = RegExp(r'^[0-9]{1,3}$');

  IPTools._(); // Prevents instantiation.

  /// Whether [ip] is an IPv4 address.
  static bool isIPv4(String ip) {
    try {
      return InternetAddress(ip).type == InternetAddressType.IPv4;
    } catch (_) {
      return false;
    }
  }

  /// Whether [ip] is an IPv4 address.
  static bool isIPv6(String ip) {
    try {
      return InternetAddress(ip).type == InternetAddressType.IPv6;
    } catch (_) {
      return false;
    }
  }

  /// Converts an IPv4 [ip] to a number.
  static BigInt? ipv4ToDecimal(String ip) {
    if (!isIPv4(ip)) return null;
    final bytes = InternetAddress(ip).rawAddress;
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }

  /// Converts an IPv6 [ip] to a number.
  static BigInt? ipv6ToDecimal(String ip) {
    if (!isIPv6(ip)) return null;
    final bytes = InternetAddress(ip).rawAddress;
    return BigInt.parse(
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16,
    );
  }

  /// Converts a number [num] to an IPv4.
  static String? decimalToIPv4(BigInt num) {
    if (num < BigInt.zero || num > maxIPv4Range) return null;
    final hex = num.toRadixString(16).padLeft(8, '0');
    final bytes = [
      for (var i = 0; i < 4; i++)
        int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    ];
    return InternetAddress.fromRawAddress(Uint8List.fromList(bytes)).address;
  }

  /// Converts a number [num] to an IPv6.
  static String? decimalToIPv6(BigInt num) {
    if (num < BigInt.zero || num > maxIPv6Range) return null;
    final hex = num.toRadixString(16).padLeft(32, '0');
    final bytes = [
      for (var i = 0; i < 16; i++)
        int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    ];
    return InternetAddress.fromRawAddress(Uint8List.fromList(bytes)).address;
  }

  /// Returns the compressed form for [ip].
  static String compressIPv6(String ip) {
    // Split into hextets
    List<String> parts = ip.split(':');

    // Removes leading zeros.
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        parts[i] = parts[i].replaceFirst(RegExp(r'^0+'), '');
        if (parts[i].isEmpty) parts[i] = '0';
      }
    }

    // Finds the longest zero run.
    int bestStart = -1;
    int bestLen = 0;
    int curStart = -1;
    int curLen = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == '0') {
        if (curStart == -1) curStart = i;
        curLen++;
      } else {
        if (curLen > bestLen) {
          bestStart = curStart;
          bestLen = curLen;
        }
        curStart = -1;
        curLen = 0;
      }
    }
    if (curLen > bestLen) {
      bestStart = curStart;
      bestLen = curLen;
    }

    // Collapses the zero run.
    if (bestLen > 1) {
      parts.replaceRange(bestStart, bestStart + bestLen, ['']);
      if (bestStart == 0) {
        parts.insert(0, '');
      }
      if (bestStart + bestLen == ip.split(':').length) {
        parts.add('');
      }
    }

    return parts.join(':').replaceAll(':::', '::');
  }

  /// Returns the expanded form for [ip].
  static String? expandIPv6(String ip) {
    if (!isIPv6(ip)) return null;
    final bytes = InternetAddress(ip).rawAddress;
    final parts = [for (var b in bytes) b.toRadixString(16).padLeft(2, '0')];
    var result = parts.join('');
    result = result.replaceAllMapped(RegExp(r'(.{4})'), (m) => '${m[1]}:');
    return result.substring(0, result.length - 1);
  }

  static String _repeat(String char, int count) =>
      List.filled(count, char).join();

  static String _joinStrings(List<String> parts, String sep) => parts.join(sep);

  /// Returns the CIDR for the IPv4 range between [ipFrom] and [ipTo].
  static List<String>? ipv4ToCidr(String ipFrom, String ipTo) {
    if (!isIPv4(ipFrom) || !isIPv4(ipTo)) return null;
    var startIP = ipv4ToDecimal(ipFrom)!.toInt();
    var endIP = ipv4ToDecimal(ipTo)!.toInt();
    List<String> result = [];

    while (endIP >= startIP) {
      var maxSize = 32;
      while (maxSize > 0) {
        final mask = (pow(2, 32) - pow(2, 32 - (maxSize - 1))).toInt();
        if ((startIP & mask) != startIP) break;
        maxSize--;
      }
      final x = log(endIP - startIP + 1) / log(2);
      final maxDiff = 32 - x.floor();
      if (maxSize < maxDiff) maxSize = maxDiff.toInt();
      result.add('${decimalToIPv4(BigInt.from(startIP))}/$maxSize');
      startIP += pow(2, 32 - maxSize).toInt();
    }
    return result;
  }

  /// Returns the CIDR for the IPv6 range between [ipFrom] and [ipTo].
  static List<String> ipv6ToCidr(String ipFrom, String ipTo) {
    final startAddress = InternetAddress(
      ipFrom,
      type: InternetAddressType.IPv6,
    );
    final endAddress = InternetAddress(ipTo, type: InternetAddressType.IPv6);

    if (startAddress.rawAddress.length != 16 ||
        endAddress.rawAddress.length != 16) {
      throw const FormatException('Invalid IPv6 address length.');
    }

    BigInt start = _ipv6BytesToBigInt(startAddress.rawAddress);
    BigInt end = _ipv6BytesToBigInt(endAddress.rawAddress);

    if (start > end) {
      throw ArgumentError('Start IP must be <= End IP.');
    }

    final List<String> cidrs = [];

    while (start <= end) {
      int prefix = 128;

      // Reduces prefix size (bigger block) while start is aligned.
      while (prefix > 0) {
        final BigInt blockSize = BigInt.one << (128 - (prefix - 1));
        if ((start % blockSize) == BigInt.zero) {
          prefix--;
        } else {
          break;
        }
      }

      // Ensures the block doesn't exceed the end IP.
      while (prefix < 128) {
        final BigInt blockEnd =
            start + (BigInt.one << (128 - prefix)) - BigInt.one;
        if (blockEnd > end) {
          prefix++;
        } else {
          break;
        }
      }

      cidrs.add('${_ipv6BigIntToAddress(start)}/$prefix');
      start += BigInt.one << (128 - prefix);
    }

    return cidrs;
  }

  static BigInt _ipv6BytesToBigInt(List<int> bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static String _ipv6BigIntToAddress(BigInt ip) {
    final List<int> bytes = List.filled(16, 0);
    BigInt temp = ip;
    for (int i = 15; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(255)).toInt();
      temp >>= 8;
    }
    return InternetAddress.fromRawAddress(
      Uint8List.fromList(bytes),
      type: InternetAddressType.IPv6,
    ).address;
  }

  /// Returns the IPv4 ranges for the [cidr].
  static List<String>? cidrToIPv4(String cidr) {
    if (!cidr.contains('/')) return null;
    final arr = cidr.split('/');
    if (arr.length != 2 ||
        !isIPv4(arr[0]) ||
        !prefixPattern.hasMatch(arr[1]) ||
        int.parse(arr[1]) > 32) {
      return null;
    }

    final prefix = int.parse(arr[1]);
    var startLong = ipv4ToDecimal(arr[0])!.toInt();
    startLong &= (-1 << (32 - prefix));
    final ipStart = decimalToIPv4(BigInt.from(startLong))!;
    var total = 1 << (32 - prefix);
    var endLong = startLong + total - 1;
    if (endLong > 4294967295) endLong = 4294967295;
    final ipEnd = decimalToIPv4(BigInt.from(endLong))!;
    return [ipStart, ipEnd];
  }

  /// Returns the IPv6 ranges for the [cidr].
  static List<String>? cidrToIPv6(String cidr) {
    if (!cidr.contains('/')) return null;
    final arr = cidr.split('/');
    if (arr.length != 2 ||
        !isIPv6(arr[0]) ||
        !prefixPattern2.hasMatch(arr[1]) ||
        int.parse(arr[1]) > 128) {
      return null;
    }

    final prefix = int.parse(arr[1]);
    final parts = expandIPv6(arr[0])!.split(':');
    final bitStart = _repeat('1', prefix) + _repeat('0', 128 - prefix);
    final bitEnd = _repeat('0', prefix) + _repeat('1', 128 - prefix);
    final chunkSize = 16;

    final floors = [
      for (var i = 0; i < bitStart.length; i += chunkSize)
        bitStart.substring(i, i + chunkSize),
    ];
    final ceilings = [
      for (var i = 0; i < bitEnd.length; i += chunkSize)
        bitEnd.substring(i, i + chunkSize),
    ];

    final startIP = <String>[];
    final endIP = <String>[];

    for (var x = 0; x < 8; x++) {
      startIP.add(
        (int.parse(parts[x], radix: 16) & int.parse(floors[x], radix: 2))
            .toRadixString(16),
      );
      endIP.add(
        (int.parse(parts[x], radix: 16) | int.parse(ceilings[x], radix: 2))
            .toRadixString(16),
      );
    }

    final hexStart = expandIPv6(_joinStrings(startIP, ':'))!;
    final hexEnd = expandIPv6(_joinStrings(endIP, ':'))!;
    return [hexStart, hexEnd];
  }
}
