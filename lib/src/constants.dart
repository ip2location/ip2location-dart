import 'dart:core';

final version = '8.0.0';

final maxIPv4Range = BigInt.from(4294967295);
final maxIPv6Range = BigInt.parse('340282366920938463463374607431768211455');

final from6to4 = BigInt.parse('42545680458834377588178886921629466624');
final to6to4 = BigInt.parse('42550872755692912415807417417958686719');

final fromTeredo = BigInt.parse('42540488161975842760550356425300246528');
final toTeredo = BigInt.parse('42540488241204005274814694018844196863');

final last32Bits = BigInt.from(4294967295);

final pattern = RegExp(
  r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
  r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
);

final pattern2 = RegExp(
  r'^([0-9A-F]{1,4}:){6}(0[0-9]+\.|.*?\.0[0-9]+).*$',
  caseSensitive: false,
);

final pattern3 = RegExp(r'^[0-9]+$');

final pattern4 = RegExp(r'^(.*:)(([0-9]+\.){3}[0-9]+)$');

final pattern5 = RegExp(r'^.*((:[0-9A-F]{1,4}){2})$');

final pattern6 = RegExp(
  r'^[0:]+((:[0-9A-F]{1,4}){1,2})$',
  caseSensitive: false,
);

final pattern7 = RegExp(
  r'^::ffff:(\d{1,3}\.){3}\d{1,3}$',
  caseSensitive: false,
);
