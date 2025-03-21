extension FastStringNullSafeExtension on String? {
  /// 默认值
  String get nullSafeOrEmpty => this ?? '';

  /// 可选默认值
  String nullSafe({String? value}) {
    return (this ?? value).nullSafeOrEmpty;
  }

  /// 如果为空抛出异常
  String nullSafeThrow({Exception? exception, String? message}) {
    if (this == null) {
      throw exception ??
          ArgumentError(message ?? 'String value should not be null');
    }
    return this!;
  }
}

extension FastStringExtension on String {
  /// 将字符串转换为小驼峰命名（to lower camel case）
  /// Convert the string into a small camel case.
  String get toCamelCase {
    if (isEmpty) return '';
    return _convertToCamelCase(this, false);
  }

  ///  将字符串转换为帕斯卡命名法：大驼峰命名 (to PascalCase)
  ///  Convert strings into Pascal nomenclature: big hump naming
  String get toPascalCase {
    if (isEmpty) return '';
    return _convertToCamelCase(this, true);
  }

  /// 将字符串转换为大蛇形命名法（Snake Case）
  /// Convert a string into a Big Snake Case.
  String get toSnakeCase {
    if (isEmpty) return '';
    return _toDelimiterNaming(this, '_').toUpperCase();
  }

  /// 将字符串转换为小蛇形命名法（Small Snake Case）
  /// Convert a string into a Big Snake Case.
  String get toSnakeCaseLower {
    if (isEmpty) return '';
    return _toDelimiterNaming(this, '_').toLowerCase();
  }

  /// 将字符串转换为字符串命名
  /// Convert a string to a string name
  String get toKebabCase {
    if (isEmpty) return '';
    return _toDelimiterNaming(this, '-').toLowerCase();
  }

  /// 验证是否为有效的URL
  /// Verify if it is a valid URL
  bool get isValidUrl =>
      RegExp(r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+[\/\?]?.*$').hasMatch(this);

  /// 验证是否为有效的手机号码
  /// Verify if it is a valid mobile phone number
  /// [region] 国家/地区代码，如 CN、US、JP 等，默认为 CN
  /// [region] Country/Region code, such as CN, US, JP, etc., default is CN
  bool isValidPhoneNumber({String region = 'CN'}) {
    final patterns = {
      'CN': r'^(\+?86)?1[3-9]\d{9}$', // 中国大陆 Mainland China
      'HK': r'^(\+?852)?[569]\d{7}$', // 香港 Hong Kong
      'TW': r'^(\+?886)?9\d{8}$', // 台湾 Taiwan
      'US': r'^(\+?1)?[2-9]\d{9}$', // 美国/加拿大 USA/Canada
      'JP': r'^(\+?81)?[789]0\d{8}$', // 日本 Japan
      'KR': r'^(\+?82)?1[0-9]{8,9}$', // 韩国 South Korea
      'SG': r'^(\+?65)?[689]\d{7}$', // 新加坡 Singapore
      'MY': r'^(\+?60)?1\d{8,9}$', // 马来西亚 Malaysia
      'TH': r'^(\+?66)?[689]\d{8}$', // 泰国 Thailand
      'VN': r'^(\+?84)?[1-9]\d{8,9}$', // 越南 Vietnam
      'IN': r'^(\+?91)?[6-9]\d{9}$', // 印度 India
      'PH': r'^(\+?63)?[24-9]\d{8,9}$', // 菲律宾 Philippines
      'ID': r'^(\+?62)?8\d{9,11}$', // 印度尼西亚 Indonesia
      'UK': r'^(\+?44)?[7-9]\d{9}$', // 英国 United Kingdom
      'DE': r'^(\+?49)?1[567]\d{8,12}$', // 德国 Germany
      'FR': r'^(\+?33)?[67]\d{8}$', // 法国 France
      'IT': r'^(\+?39)?3\d{9}$', // 意大利 Italy
      'ES': r'^(\+?34)?[6-7]\d{8}$', // 西班牙 Spain
      'AU': r'^(\+?61)?4\d{8}$', // 澳大利亚 Australia
      'NZ': r'^(\+?64)?2\d{7,9}$', // 新西兰 New Zealand
    };

    final pattern = patterns[region.toUpperCase()];
    if (pattern == null) return false;

    return RegExp(pattern).hasMatch(this);
  }

  /// 格式化手机号码
  /// Format phone number
  /// [region] 国家/地区代码，如 CN、US、JP 等，默认为 CN
  /// [region] Country/Region code, such as CN, US, JP, etc., default is CN
  String formatPhoneNumber({String region = 'CN'}) {
    if (!isValidPhoneNumber(region: region)) return this;

    final formats = {
      'CN': (String number) {
        final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length != 11) return number;
        return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
      },
      'US': (String number) {
        final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length != 10) return number;
        return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
      },
      'JP': (String number) {
        final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.length != 10 && cleaned.length != 11) return number;
        return cleaned.length == 11
            ? '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}'
            : '${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
      }
    };

    final formatter = formats[region.toUpperCase()];
    return formatter != null ? formatter(this) : this;
  }

  /// 私有方法：字符串首字母转大写
  /// Private method: the first letter of the string is capitalized.
  String _capitalizeFirstLetter(String str) =>
      str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : str;

  /// 私有方法：根据正则表达式分割单词
  /// Private method: divide words according to regular expressions.
  List<String> _splitWords(String str) => str
      .split(RegExp(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|[_\-\s.]+'))
      .where((word) => word.isNotEmpty)
      .toList();

  /// 私有方法：将字符串转换为带分隔符的命名法
  /// Private method: Convert a string to a delimited naming method.
  String _toDelimiterNaming(String str, [String delimiter = ' ']) {
    final List<String> words = _splitWords(str);
    return words.join(delimiter);
  }

  /// 私有方法：将字符串转为驼峰命名
  /// Private method: convert the string into hump naming.
  String _convertToCamelCase(String str, bool upperCamelCase) {
    final List<String> words = _splitWords(str);
    if (words.isEmpty) return '';

    final List<String> capitalizedWords =
        words.map((word) => _capitalizeFirstLetter(word)).toList();
    if (upperCamelCase) {
      return capitalizedWords.join();
    } else {
      return capitalizedWords[0].toLowerCase() +
          capitalizedWords.sublist(1).join();
    }
  }
}
