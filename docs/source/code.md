# IP2Location Dart API

## IP2Location Class

```{py:class} IP2Location(databasePath)
Initiate IP2Location class.

:param String databasePath: (Required) The file path links to IP2Location BIN databases.
```

```{py:function} getAll(ipAddress)
Retrieve geolocation information for an IP address.

:param String ipAddress: (Required) The IP address (IPv4 or IPv6).
:return: Returns the geolocation information in an object. Refer below table for the fields avaliable in the object
:rtype: object

**RETURN FIELDS**

| Field Name       | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| countryShort    |     Two-character country code based on ISO 3166. |
| countryLong     |     Country name based on ISO 3166. |
| region           |     Region or state name. |
| city             |     City name. |
| isp              |     Internet Service Provider or company\'s name. |
| latitude         |     City latitude. Defaults to capital city latitude if city is unknown. |
| longitude        |     City longitude. Defaults to capital city longitude if city is unknown. |
| domain           |     Internet domain name associated with IP address range. |
| zipCode          |     ZIP code or Postal code. [172 countries supported](https://www.ip2location.com/zip-code-coverage). |
| timeZone         |     UTC time zone (with DST supported). |
| netSpeed         |     Internet connection type. |
| iddCode         |     The IDD prefix to call the city from another country. |
| areaCode        |     A varying length number assigned to geographic areas for calls between cities. [223 countries supported](https://www.ip2location.com/area-code-coverage). |
| weatherStationCode     |     The special code to identify the nearest weather observation station. |
| weatherStationName     |     The name of the nearest weather observation station. |
| mcc              |     Mobile Country Codes (MCC) as defined in ITU E.212 for use in identifying mobile stations in wireless telephone networks, particularly GSM and UMTS networks. |
| mnc              |     Mobile Network Code (MNC) is used in combination with a Mobile Country Code(MCC) to uniquely identify a mobile phone operator or carrier. |
| mobileBrand     |     Commercial brand associated with the mobile carrier. You may click [mobile carrier coverage](https://www.ip2location.com/mobile-carrier-coverage) to view the coverage report. |
| elevation        |     Average height of city above sea level in meters (m). |
| usageType       |     Usage type classification of ISP or company. |
| addressType     |     IP address types as defined in Internet Protocol version 4 (IPv4) and Internet Protocol version 6 (IPv6). |
| category         |     The domain category based on [IAB Tech Lab Content Taxonomy](https://www.ip2location.com/free/iab-categories). |
| district         |     District or county name. |
| asn              |     Autonomous system number (ASN). BIN databases. |
| asName          |     Autonomous system (AS) name. |
```

## IPTools Class

```{py:class} IPTools ()
Initiate IPTools class.
```

```{py:function} isIPv4(ip)
Verify if a string is a valid IPv4 address.

:param String ip: (Required) IP address.
:return: Return True if the IP address is a valid IPv4 address or False if it isn't a valid IPv4 address.
:rtype: boolean
```

```{py:function} isIPv6(ip)
Verify if a string is a valid IPv6 address

:param String ip: (Required) IP address.
:return: Return True if the IP address is a valid IPv6 address or False if it isn't a valid IPv6 address.
:rtype: boolean
```

```{py:function} ipv4ToDecimal(ip)
Translate IPv4 address from dotted-decimal address to decimal format.

:param String ip: (Required) IPv4 address.
:return: Return the decimal format of the IPv4 address.
:rtype: BigInt
```

```{py:function} decimalToIPv4(num)
Translate IPv4 address from decimal number to dotted-decimal address.

:param BigInt num: (Required) Decimal format of the IPv4 address.
:return: Returns the dotted-decimal format of the IPv4 address.
:rtype: string
```

```{py:function} ipv6ToDecimal(ip)
Translate IPv6 address from hexadecimal address to decimal format.

:param String ip: (Required) IPv6 address.
:return: Return the decimal format of the IPv6 address.
:rtype: BigInt
```

```{py:function} decimalToIPv6(num)
Translate IPv6 address from decimal number into hexadecimal address.

:param BigInt num: (Required) Decimal format of the IPv6 address.
:return: Returns the hexadecimal format of the IPv6 address.
:rtype: string
```

```{py:function} ipv4ToCidr(ipFrom, ipTo)
Convert IPv4 range into a list of IPv4 CIDR notation.

:param String ipFrom: (Required) The starting IPv4 address in the range.
:param String ipTo: (Required) The ending IPv4 address in the range.
:return: Returns the list of IPv4 CIDR notation.
:rtype: list
```

```{py:function} cidrToIPv4(cidr)
Convert IPv4 CIDR notation into a list of IPv4 addresses.

:param String cidr: (Required) IPv4 CIDR notation.
:return: Returns an list of IPv4 addresses.
:rtype: list
```

```{py:function} ipv6ToCidr(ipFrom, ipTo)
Convert IPv6 range into a list of IPv6 CIDR notation.

:param String ipFrom: (Required) The starting IPv6 address in the range.
:param String ipTo: (Required) The ending IPv6 address in the range.
:return: Returns the list of IPv6 CIDR notation.
:rtype: list
```

```{py:function} cidrToIPv6(cidr)
Convert IPv6 CIDR notation into a list of IPv6 addresses.

:param String cidr: (Required) IPv6 CIDR notation.
:return: Returns an list of IPv6 addresses.
:rtype: list
```

```{py:function} compressIPv6(ip)
Compress a IPv6 to shorten the length.

:param String ip: (Required) IPv6 address.
:return: Returns the compressed version of IPv6 address.
:rtype: String
```

```{py:function} ExpandIPv6(ip)
Expand a compressed IPv6 to full length.

:param String ip: (Required) IPv6 address.
:return: Returns the extended version of IPv6 address.
:rtype: String
```

## Country Class

```{py:function} fromFile(csvFile)
Load the IP2Location Country Information CSV file. This database is free for download at <https://www.ip2location.com/free/country-information>.

:param String csvFile: (Required) The file path links to IP2Location Country Information CSV file.
```

```{py:function} getCountryInfo(countryCode)
Provide a ISO 3166 country code to get the country information in list.

:param String countryCode: (Required) The ISO 3166 country code of a country.
:return: Returns the country information in list. Refer below table for the fields avaliable in the list.
:rtype: list
```

```{py:function} getAllCountryInfo()
Provide a ISO 3166 country code to get all countries' information in list.

:return: Returns the country information in list. Refer below table for the fields avaliable in the list.
:rtype: list
```

**RETURN FIELDS**

| Field Name       | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| country_code     | Two-character country code based on ISO 3166.                |
| country_alpha3_code | Three-character country code based on ISO 3166.           |
| country_numeric_code | Three-character country code based on ISO 3166.          |
| capital          | Capital of the country.                                      |
| country_demonym  | Demonym of the country.                                      |
| total_area       | Total area in km{sup}`2`.                                    |
| population       | Population of year 2014.                                     |
| idd_code         | The IDD prefix to call the city from another country.        |
| currency_code    | Currency code based on ISO 4217.                             |
| currency_name    | Currency name.                                               |
| currency_symbol  | Currency symbol.                                             |
| lang_code        | Language code based on ISO 639.                              |
| lang_name        | Language name.                                               |
| cctld            | Country-Code Top-Level Domain.                               |

## Region Class

```{py:function} fromFile(csvFile)
Load the IP2Location ISO 3166-2 Subdivision Code CSV file. This database is free for download at <https://www.ip2location.com/free/iso3166-2>

:param String csvFile: (Required) The file path links to IP2Location ISO 3166-2 Subdivision Code CSV file.
```

```{py:function} getRegionCode(countryCode, regionName)
Provide a ISO 3166 country code and the region name to get ISO 3166-2 subdivision code for the region.

:param String countryCode: (Required) Two-character country code based on ISO 3166.
:param String regionName: (Required) Region or state name.
:return: Returns the ISO 3166-2 subdivision code of the region.
:rtype: String
```