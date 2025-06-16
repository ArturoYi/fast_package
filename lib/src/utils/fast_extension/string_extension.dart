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

  /// 是否为空
  bool get isNullOrEmpty => this == null || this!.isEmpty;
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
