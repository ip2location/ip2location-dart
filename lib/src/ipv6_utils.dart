import 'dart:core';
import 'constants.dart';

/// Returns the expanded IPv6 for [myIP] and [myIpType].
List<String> expandIPv6(String myIP, int myIpType) {
  const String tmp = '0000:0000:0000:0000:0000:';
  const String padMe = '0000';
  const int hexOffset = 0xFF;
  String myIP2 = myIP.toUpperCase();
  String retType = myIpType.toString();

  if (myIpType == 4) {
    if (pattern4.hasMatch(myIP2)) {
      myIP2 = myIP2.replaceAll('::', tmp);
    } else {
      final mat = pattern5.firstMatch(myIP2);
      if (mat != null) {
        String myMatch = mat.group(1)!;
        List<String> myArr = myMatch
            .replaceAll(RegExp(r'^:+'), '')
            .replaceAll(RegExp(r':+$'), '')
            .split(':');
        StringBuffer bf = StringBuffer();

        for (var segment in myArr) {
          bf.write(padMe.substring(segment.length));
          bf.write(segment);
        }

        BigInt big = BigInt.parse(bf.toString(), radix: 16);
        List<int> b = List.filled(4, 0);

        for (int x = 0; x < 4; x++) {
          b[x] = (big.toInt() & hexOffset);
          big = big >> 8;
        }

        myIP2 = myIP2.replaceAll(
          '$myMatch'
              r'$',
          ':${b[3]}.${b[2]}.${b[1]}.${b[0]}',
        );
        myIP2 = myIP2.replaceAll('::', tmp);
      }
    }
  } else if (myIpType == 6) {
    if (myIP2 == '::') {
      myIP2 = '${myIP2}0.0.0.0';
      myIP2 = myIP2.replaceAll('::', '${tmp}FFFF:');
      retType = '4';
    } else {
      final mat = pattern4.firstMatch(myIP2);
      if (mat != null) {
        String v6part = mat.group(1)!;
        String v4part = mat.group(2)!;

        List<int> v4IntArr = v4part.split('.').map(int.parse).toList();
        int part1 = (v4IntArr[0] << 8) + v4IntArr[1];
        int part2 = (v4IntArr[2] << 8) + v4IntArr[3];

        String part1hex = part1.toRadixString(16);
        String part2hex = part2.toRadixString(16);

        StringBuffer bf = StringBuffer();
        bf.write(v6part);
        bf.write(padMe.substring(part1hex.length));
        bf.write(part1hex);
        bf.write(':');
        bf.write(padMe.substring(part2hex.length));
        bf.write(part2hex);

        myIP2 = bf.toString().toUpperCase();

        List<String> myArr = myIP2.split('::');
        List<String> leftSide = myArr[0].split(':');

        StringBuffer bf2 = StringBuffer();
        StringBuffer bf3 = StringBuffer();
        StringBuffer bf4 = StringBuffer();

        int totalSegments = 0;
        for (var s in leftSide) {
          if (s.isNotEmpty) {
            totalSegments++;
            bf2.write(padMe.substring(s.length));
            bf2.write(s);
            bf2.write(':');
          }
        }

        if (myArr.length > 1) {
          List<String> rightSide = myArr[1].split(':');
          for (var s in rightSide) {
            if (s.isNotEmpty) {
              totalSegments++;
              bf3.write(padMe.substring(s.length));
              bf3.write(s);
              bf3.write(':');
            }
          }
        }

        int totalSegmentsLeft = 8 - totalSegments;

        if (totalSegmentsLeft == 6) {
          for (int x = 1; x < totalSegmentsLeft; x++) {
            bf4.write(padMe);
            bf4.write(':');
          }
          bf4.write('FFFF:');
          bf4.write(v4part);
          retType = '4';
          myIP2 = bf4.toString();
        } else {
          for (int x = 0; x < totalSegmentsLeft; x++) {
            bf4.write(padMe);
            bf4.write(':');
          }
          bf2
            ..write(bf4)
            ..write(bf3);
          myIP2 = bf2.toString().replaceAll(RegExp(r':$'), '');
        }
      } else {
        final mat2 = pattern6.firstMatch(myIP2);
        if (mat2 != null) {
          String myMatch = mat2.group(1)!;
          List<String> myArr = myMatch
              .replaceAll(RegExp(r'^:+'), '')
              .replaceAll(RegExp(r':+$'), '')
              .split(':');

          StringBuffer bf = StringBuffer();
          for (var segment in myArr) {
            bf.write(padMe.substring(segment.length));
            bf.write(segment);
          }

          BigInt big = BigInt.parse(bf.toString(), radix: 16);
          List<int> b = List.filled(4, 0);

          for (int x = 0; x < 4; x++) {
            b[x] = (big.toInt() & hexOffset);
            big = big >> 8;
          }

          myIP2 = myIP2.replaceAll(
            '$myMatch'
                r'$',
            ':${b[3]}.${b[2]}.${b[1]}.${b[0]}',
          );
          myIP2 = myIP2.replaceAll('::', '${tmp}FFFF:');
          retType = '4';
        } else {
          List<String> myArr = myIP2.split('::');

          List<String> leftSide = myArr[0].split(':');
          StringBuffer bf2 = StringBuffer();
          StringBuffer bf3 = StringBuffer();
          StringBuffer bf4 = StringBuffer();

          int totalSegments = 0;
          for (var s in leftSide) {
            if (s.isNotEmpty) {
              totalSegments++;
              bf2.write(padMe.substring(s.length));
              bf2.write(s);
              bf2.write(':');
            }
          }

          if (myArr.length > 1) {
            List<String> rightSide = myArr[1].split(':');
            for (var s in rightSide) {
              if (s.isNotEmpty) {
                totalSegments++;
                bf3.write(padMe.substring(s.length));
                bf3.write(s);
                bf3.write(':');
              }
            }
          }

          int totalSegmentsLeft = 8 - totalSegments;
          for (int x = 0; x < totalSegmentsLeft; x++) {
            bf4.write(padMe);
            bf4.write(':');
          }

          bf2
            ..write(bf4)
            ..write(bf3);
          myIP2 = bf2.toString().replaceAll(RegExp(r':$'), '');
        }
      }
    }
  }

  return [myIP2, retType];
}
