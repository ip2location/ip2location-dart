import 'package:ip2location/iptools.dart';

void main() {
  var ip = '8.8.8.8';
  print(IPTools.isIPv4(ip));

  ip = '175.144.140.232';
  print(IPTools.ipv4ToDecimal(ip));

  ip = '2600:1f18:45b0:5b00:f5d8:4183:7710:ceec';
  print(IPTools.isIPv6(ip));

  ip = '2600:1f18:45b0:5b00:f5d8:4183:7710:ceec';
  print(IPTools.ipv6ToDecimal(ip));

  var ipNum = 2945486056;
  print(IPTools.decimalToIPv4(BigInt.from(ipNum)));

  var ipNumStr = '22398978840339333967292465152';
  print(IPTools.decimalToIPv6(BigInt.parse(ipNumStr)));

  ip = '2600:1f18:045b:005b:f5d8:0:000:ceec';
  print(IPTools.compressIPv6(ip));

  ip = '::45b:05b:f5d8:0:000:ceec';
  print(IPTools.expandIPv6(ip));

  var ipFrom = '10.0.0.0';
  var ipTo = '10.10.2.255';
  print(IPTools.ipv4ToCidr(ipFrom, ipTo));

  ipFrom = '2001:4860:4860:0000:0000:0000:0000:8888';
  ipTo = '2001:4860:4860:0000:eeee:ffff:ffff:ffff';
  print(IPTools.ipv6ToCidr(ipFrom, ipTo));

  var cidr = '123.245.99.13/26';
  print(IPTools.cidrToIPv4(cidr));

  cidr = '2002:1234::abcd:ffff:c0a8:101/62';
  print(IPTools.cidrToIPv6(cidr));
}
