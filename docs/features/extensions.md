---
title: 扩展函数
---

### 字符串扩展

提供丰富的字符串转换和格式化功能。

```dart
// 将字符串转换为小驼峰命名（to lower camel case）
String get toCamelCase;
// 示例:
// "hello_world" => "helloWorld"
// "user-name" => "userName"
// "FirstName" => "firstName"

// 将字符串转换为帕斯卡命名法：大驼峰命名 (to PascalCase)
String get toPascalCase;
// 示例:
// "hello_world" => "HelloWorld"
// "user-name" => "UserName"
// "firstName" => "FirstName"

// 将字符串转换为大蛇形命名法（Snake Case）
String get toSnakeCase;
// 示例:
// "helloWorld" => "HELLO_WORLD"
// "user-name" => "USER_NAME"
// "FirstName" => "FIRST_NAME"

// 将字符串转换为小蛇形命名法（Small Snake Case）
String get toSnakeCaseLower;
// 示例:
// "helloWorld" => "hello_world"
// "user-name" => "user_name"
// "FirstName" => "first_name"

// 将字符串转换为短横线命名法（Kebab Case）
String get toKebabCase;
// 示例:
// "helloWorld" => "hello-world"
// "user_name" => "user-name"
// "FirstName" => "first-name"
```

### 空安全扩展

为各种数据类型提供安全的空值处理扩展。

```dart
// 字符串空安全扩展
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default")); // "default"
print(str.nullSafeThrow()); // Throws: Value should not be null

// 数字空安全扩展
int? num = null;
print(num.nullSafeOrZero); // 0
print(num.nullSafe(42)); // 42

// 布尔值空安全扩展
bool? flag = null;
print(flag.nullSafeOrFalse); // false
print(flag.nullSafe(true)); // true
```

### 数字扩展

提供数字格式化和转换功能。

```dart
// 数字格式化
double price = 1234.5678;
print(price.toCurrency()); // "¥1,234.57"
print(price.toPercent()); // "123,456.78%"

// 数字转换
int count = 1000;
print(count.toFileSize()); // "1.0 KB"
print(count.toDuration()); // "16 minutes 40 seconds"
```
