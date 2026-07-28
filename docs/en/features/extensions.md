---
title: Extensions
outline: [2, 3]
---

## Overview {#overview}

Import `package:fast_package/fast_package.dart` to use Dart **extensions** on `String` / nullable strings, nullable `bool` / `int` / `double` / `num`, and non-null `num`. APIs are **getters or instance methods**; they do not change the underlying types.

| Extension | Receiver | Summary |
| --- | --- | --- |
| `FastStringExtension` | `String` | camel / snake / kebab case, `isValidUrl` |
| `FastStringNullSafeExtension` | `String?` | empty defaults, optional default, non-null assert |
| `FastBoolNullSafeExtension` | `bool?` | default `false` / `true`, optional default |
| `FastNumExtension` | `num` | range check, divisibility |
| `FastNumNullSafeExtension` etc. | `num?` / `int?` / `double?` | zero defaults and `nullSafeThrow` |

---

## String case {#string-case}

`FastStringExtension` splits on word boundaries (spaces, `-`, `_`, `.`, and camelCase breaks), then rejoins. Empty string → `''`.

### Examples {#string-case-example}

```dart
'hello_world'.toCamelCase;      // helloWorld
'user-name'.toPascalCase;       // UserName
'helloWorld'.toSnakeCase;       // HELLO_WORLD
'FirstName'.toSnakeCaseLower;   // first_name
'hello_world'.toKebabCase;      // hello-world

'https://example.com'.isValidUrl; // true
```

### API reference {#string-case-api}

---

#### `toCamelCase` / `toPascalCase` {#string-to-camel-pascal}

Lower camelCase (first word lowercase) and PascalCase (each word capitalized).

|  | Type | Description |
| --- | --- | --- |
| Return | `String` (getter) | Converted name; `''` when `isEmpty`. |

---

#### `toSnakeCase` / `toSnakeCaseLower` {#string-to-snake}

UPPER_SNAKE and lower_snake.

|  | Type | Description |
| --- | --- | --- |
| Return | `String` (getter) | Words joined with `_`. |

---

#### `toKebabCase` {#string-to-kebab}

Lowercase kebab-case with `-`.

|  | Type | Description |
| --- | --- | --- |
| Return | `String` (getter) | Words joined with `-`. |

---

#### `isValidUrl` {#string-is-valid-url}

Rough URL check via built-in regex (optional `http`/`https`).

|  | Type | Description |
| --- | --- | --- |
| Return | `bool` (getter) | `true` when matched. |

---

## Nullable strings {#string-null-safe}

`FastStringNullSafeExtension on String?`.

### Examples {#string-null-safe-example}

```dart
String? name;
name.nullSafeOrEmpty;           // ''
name.nullSafe(value: 'guest');  // guest
name.isNullOrEmpty;             // true

name.nullSafeThrow(); // throws ArgumentError when null (optional message / exception)
```

### API reference {#string-null-safe-api}

---

#### `nullSafeOrEmpty` {#string-null-safe-or-empty}

|  | Type | Description |
| --- | --- | --- |
| Return | `String` (getter) | `null` → `''`. |

---

#### `nullSafe` {#string-null-safe-null-safe}

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `value` | `String?` | no | Fallback when `null`; still empty → `nullSafeOrEmpty`. |

| Return | Type | Description |
| --- | --- | --- |
| — | `String` | Use `this` when non-null; else `value` then empty fallback. |

---

#### `nullSafeThrow` {#string-null-safe-throw}

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `exception` | `Exception?` | no | Custom exception; default `ArgumentError`. |
| `message` | `String?` | no | Default message when no `exception`. |

| Return | Type | Description |
| --- | --- | --- |
| — | `String` | Returns self when non-null. |

---

#### `isNullOrEmpty` {#string-is-null-or-empty}

|  | Type | Description |
| --- | --- | --- |
| Return | `bool` (getter) | `true` for `null` or `''`. |

---

## Nullable booleans {#bool-null-safe}

`FastBoolNullSafeExtension on bool?`.

### Examples {#bool-null-safe-example}

```dart
bool? flag;
flag.nullSafeOrFalse;  // false
flag.nullSafeOrTrue;   // true
flag.nullSafe(value: true); // true
```

### API reference {#bool-null-safe-api}

| API | Return | Description |
| --- | --- | --- |
| `nullSafeOrFalse` | `bool` | `null` → `false` |
| `nullSafeOrTrue` | `bool` | `null` → `true` |
| `nullSafe({bool? value})` | `bool` | Fallback via `value`, then `nullSafeOrFalse` |
| `nullSafeThrow({Exception? exception})` | `bool` | Throw when null; else self |

---

## Number utilities {#num-utils}

`FastNumExtension on num` (non-null).

### Examples {#num-utils-example}

```dart
5.isBetween(1, 10);   // true (closed interval; argument order ignored)
10.isDivisibleBy(2);  // true
10.isDivisibleBy(0);  // false (divisor 0)
```

### API reference {#num-utils-api}

---

#### `isBetween` {#num-is-between}

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `betweenOne` | `num` | yes | One end of the interval |
| `betweenTwo` | `num` | yes | Other end |

| Return | Type | Description |
| --- | --- | --- |
| — | `bool` | Whether `this` lies in the closed interval |

---

#### `isDivisibleBy` {#num-is-divisible-by}

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `divisor` | `num` | yes | Divisor; `0` → `false` |

| Return | Type | Description |
| --- | --- | --- |
| — | `bool` | Whether division is exact |

---

## Nullable numbers {#num-null-safe}

Separate extensions for `int?`, `double?`, and `num?` with the same shape; zero defaults are `0`, `0.0`, and `0`.

### Examples {#num-null-safe-example}

```dart
int? count;
count.nullSafeOrEmpty;        // 0
count.nullSafe(value: 42);    // 42
count.nullSafeThrow();        // null → ArgumentError

double? rate;
rate.nullSafeOrEmpty;         // 0.0
```

### API reference {#num-null-safe-api}

Each type provides:

| API | Description |
| --- | --- |
| `nullSafeOrEmpty` | Zero value when `null` |
| `nullSafe({T? value})` | Optional default, then zero fallback |
| `nullSafeThrow({Exception? exception})` | Non-null assert |

Types: `FastIntNullSafeExtension`, `FastDoubleNullSafeExtension`, `FastNumNullSafeExtension`.
