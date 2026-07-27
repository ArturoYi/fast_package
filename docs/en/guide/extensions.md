---
title: Extensions
---

### String Extensions

Provides rich string conversion and formatting functionality.

```dart
// Convert the string into a small camel case
String get toCamelCase;
// Examples:
// "hello_world" => "helloWorld"
// "user-name" => "userName"
// "FirstName" => "firstName"

// Convert strings into Pascal nomenclature: big hump naming
String get toPascalCase;
// Examples:
// "hello_world" => "HelloWorld"
// "user-name" => "UserName"
// "firstName" => "FirstName"

// Convert a string into a Big Snake Case
String get toSnakeCase;
// Examples:
// "helloWorld" => "HELLO_WORLD"
// "user-name" => "USER_NAME"
// "FirstName" => "FIRST_NAME"

// Convert a string into a Small Snake Case
String get toSnakeCaseLower;
// Examples:
// "helloWorld" => "hello_world"
// "user-name" => "user_name"
// "FirstName" => "first_name"

// Convert a string to a kebab case
String get toKebabCase;
// Examples:
// "helloWorld" => "hello-world"
// "user_name" => "user-name"
// "FirstName" => "first-name"
```

### Null Safety Extensions

Provides safe null value handling extensions for various data types.

```dart
// String null safety extensions
String? str = null;
print(str.nullSafeOrEmpty); // ""
print(str.nullSafe("default")); // "default"
print(str.nullSafeThrow()); // Throws: Value should not be null

// Number null safety extensions
int? num = null;
print(num.nullSafeOrZero); // 0
print(num.nullSafe(42)); // 42

// Boolean null safety extensions
bool? flag = null;
print(flag.nullSafeOrFalse); // false
print(flag.nullSafe(true)); // true
```

### Number Extensions

Provides number formatting and conversion functionality.

```dart
// Number formatting
double price = 1234.5678;
print(price.toCurrency()); // "¥1,234.57"
print(price.toPercent()); // "123,456.78%"

// Number conversion
int count = 1000;
print(count.toFileSize()); // "1.0 KB"
print(count.toDuration()); // "16 minutes 40 seconds"
```
