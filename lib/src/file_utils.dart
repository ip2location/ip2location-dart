import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Reads data from a file based on [position], [length] and [file].
Future<Uint8List> readRow({
  required int position,
  required int length,
  required RandomAccessFile file,
}) async {
  final row = Uint8List(length);
  await file.setPosition(position - 1);
  await file.readInto(row, 0, length);
  return row;
}

/// Reads a 32-bit or 128-bit integer based on [row], [from] and [len].
BigInt read32or128Row(Uint8List row, int from, int len) {
  // Extracts the bytes and reverse little-endian to big-endian.
  final reversed = row.sublist(from, from + len).reversed.toList();

  // Converts to hex string (BigInt requires big-endian).
  final hex = reversed.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  // Parses as unsigned BigInt.
  return BigInt.parse(hex, radix: 16);
}

/// Reads a 32-bit integer based on [row] and [from].
int read32Row(Uint8List row, int from) {
  const len = 4;
  final byteData = ByteData.sublistView(row, from, from + len);
  return byteData.getUint32(0, Endian.little);
}

/// Reads a string from file based on [position] and [file].
Future<String?> readStr({
  required int position,
  required RandomAccessFile file,
}) async {
  var size = 256; // max string length in BIN file + 1 byte for the length value
  final data = Uint8List(size);
  await file.setPosition(position);
  await file.readInto(data, 0, size);

  final len = data[0];

  final buf = data.sublist(1, 1 + len);
  return utf8.decode(buf, allowMalformed: true);
}

/// Reads a 32-bit float based on [row] and [from].
double readFloatRow(Uint8List row, int from) {
  return ByteData.sublistView(row, from, from + 4).getFloat32(0, Endian.little);
}

/// Parses a float string [s] into 32-bit float.
double parseFloat32(String s) {
  final buffer = ByteData(4);
  buffer.setFloat32(0, double.tryParse(s) ?? 0.0, Endian.little);
  return buffer.getFloat32(0, Endian.little);
}
