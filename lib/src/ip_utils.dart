import 'dart:io';
import 'dart:typed_data';
import 'constants.dart';

/// Converts an IPv4 or IPv6 address string to:
/// [IP type, Numeric representation, Original type]
///
/// Returns a list of 3 BigInts:
/// - index 0: detected type (4 or 6)
/// - index 1: numeric value
/// - index 2: original type (4 or 6)
List<BigInt> ip2No(String ipString) {
  late BigInt a1;
  late BigInt a2;
  BigInt a3 = BigInt.from(4);

  // IPv4 address pattern.
  if (pattern.hasMatch(ipString)) {
    a1 = BigInt.from(4);
    a2 = BigInt.from(ipV4No(ipString));
  }
  // Invalid forms of IP addresses.
  else if (pattern2.hasMatch(ipString) || pattern3.hasMatch(ipString)) {
    throw Exception('Invalid IP address format');
  }
  // IPv6 or IPv4-mapped IPv6 patterns.
  else {
    a3 = BigInt.from(6);
    final internetAddress = InternetAddress(ipString);
    final rawBytes = internetAddress.rawAddress;

    a2 = _unsignedBigInt(rawBytes);

    String myIpType = '0';

    if (pattern7.hasMatch(ipString)) {
      // IPv4-mapped IPv6 case.
      myIpType = '4';

      // Converts to plain IPv4 string.
      var ip = ipString.toLowerCase().split('::ffff:').last;
      final ia = InternetAddress(ip);
      final rb = ia.rawAddress;
      a2 = _unsignedBigInt(rb);
    } else if (internetAddress.type == InternetAddressType.IPv6) {
      myIpType = '6';
    } else if (internetAddress.type == InternetAddressType.IPv4) {
      // Just in case anything slips through.
      myIpType = '4';
    }

    // Converts 6to4 to plain IPv4 address.
    if (a2.compareTo(from6to4) >= 0 && a2.compareTo(to6to4) <= 0) {
      myIpType = '4';
      a2 = a2 >> 80;
      a2 = a2 & last32Bits;
      a3 = BigInt.from(4);
    }
    // Converts Teredo to plain IPv4 address.
    else if (a2.compareTo(fromTeredo) >= 0 && a2.compareTo(toTeredo) <= 0) {
      myIpType = '4';
      a2 = ~a2;
      a2 = a2 & last32Bits;
      a3 = BigInt.from(4);
    }

    a1 = BigInt.parse(myIpType);
  }

  return [a1, a2, a3];
}

/// Converts an IPv4 [ipString] to integer.
int ipV4No(String ipString) {
  final parts = ipString.split('.');
  int result = 0;

  for (int i = 3; i >= 0; i--) {
    final ipPart = int.parse(parts[3 - i]);
    result |= ipPart << (i * 8);
  }
  return result;
}

/// Converts [bytes] to unsigned BigInt.
BigInt _unsignedBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;
  for (final b in bytes) {
    result = (result << 8) | BigInt.from(b & 0xff);
  }
  return result;
}
