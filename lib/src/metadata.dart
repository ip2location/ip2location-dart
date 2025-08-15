/// Stores all the metadata about the BIN file.
class MetaData {
  late int baseAddress;
  late int dbCount;
  late int dbColumn;
  late int dbType;
  late int dbDay;
  late int dbMonth;
  late int dbYear;
  late int baseAddressIPv6;
  late int dbCountIPv6;
  late bool oldBin;
  late bool indexed;
  late bool indexedIPv6;
  late int indexBaseAddress;
  late int indexBaseAddressIPv6;
  late int productCode;
  late int productType;
  late int fileSize;

  MetaData({
    this.baseAddress = 0,
    this.dbCount = 0,
    this.dbColumn = 0,
    this.dbType = 0,
    this.dbDay = 1,
    this.dbMonth = 1,
    this.dbYear = 1,
    this.baseAddressIPv6 = 0,
    this.dbCountIPv6 = 0,
    this.oldBin = false,
    this.indexed = false,
    this.indexedIPv6 = false,
    this.indexBaseAddress = 0,
    this.indexBaseAddressIPv6 = 0,
    this.productCode = 0,
    this.productType = 0,
    this.fileSize = 0,
  });
}
