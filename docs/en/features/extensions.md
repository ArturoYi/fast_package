---
title: Extensions
---

### String extensions

Rich string conversion and formatting helpers.

```dart
// Convert to lower camelCase
String get toCamelCase;
// Examples:
// "hello_world" => "helloWorld"
// "user-name" => "userName"
// "FirstName" => "firstName"

// Convert to PascalCase (upper camelCase)
String get toPascalCase;
// Examples:
// "hello_world" => "HelloWorld"
// "user-name" => "UserName"
// "firstName" => "FirstName"

// Convert to UPPER_SNAKE_CASE
String get toSnakeCase;
// Examples:
// "helloWorld" => "HELLO_WORLD"
// "user-name" => "USER_NAME"
// "FirstName" => "FIRST_NAME"

// Convert to lower_snake_case
String get toSnakeCaseLower;
// Examples:
// "helloWorld" => "hello_world"
// "user-name" => "user_name"
// "FirstName" => "first_name"

// Convert to kebab-case
String get toKebabCase;
// Examples:
// "helloWorld" => "hello-world"
// "user_name" => "user-name"
// "FirstName" => "first-name"
```

### Null-safety extensions

Safe null handling for common types.

```dart
// String
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default")); // "default"
print(str.nullSafeThrow()); // Throws: Value should not be null

// Numbers
int? num = null;
print(num.nullSafeOrZero); // 0
print(num.nullSafe(42)); // 42

// Booleans
bool? flag = null;
print(flag.nullSafeOrFalse); // false
print(flag.nullSafe(true)); // true
```

### Number extensions

Formatting and conversion utilities.

```dart
// Formatting
double price = 1234.5678;
print(price.toCurrency()); // "¥1,234.57"
print(price.toPercent()); // "123,456.78%"

// Conversion
int count = 1000;
print(count.toFileSize()); // "1.0 KB"
print(count.toDuration()); // "16 minutes 40 seconds"
```
