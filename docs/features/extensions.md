---
title: 扩展函数
outline: [2, 3]
---

## 概览 {#overview}

通过 `import 'package:fast_package/fast_package.dart';` 使用 Dart **extension**，在 `String` / 可空字符串、可空 `bool` / `int` / `double` / `num` 以及非空 `num` 上提供命名转换、空值默认值与常用数值判断。扩展方法为 **getter 或实例方法**，不改变原类型定义。

| 扩展 | 接收者 | 作用概要 |
| --- | --- | --- |
| `FastStringExtension` | `String` | 驼峰 / 蛇形 / 短横线命名、`isValidUrl` |
| `FastStringNullSafeExtension` | `String?` | 空串默认、可选默认、非空断言 |
| `FastBoolNullSafeExtension` | `bool?` | 默认 `false` / `true`、可选默认 |
| `FastNumExtension` | `num` | 区间判断、整除判断 |
| `FastNumNullSafeExtension` 等 | `num?` / `int?` / `double?` | 各类型空值默认与 `nullSafeThrow` |

---

## 字符串命名 {#string-case}

`FastStringExtension` 按单词边界（空格、`-`、`_`、`.` 及驼峰切分）拆分后重组；空字符串返回 `''`。

### 基础使用示例 {#string-case-example}

```dart
'hello_world'.toCamelCase;      // helloWorld
'user-name'.toPascalCase;       // UserName
'helloWorld'.toSnakeCase;       // HELLO_WORLD
'FirstName'.toSnakeCaseLower;   // first_name
'hello_world'.toKebabCase;      // hello-world

'https://example.com'.isValidUrl; // true
```

### 完整 API 参考 {#string-case-api}

---

#### `toCamelCase` / `toPascalCase` {#string-to-camel-pascal}

小驼峰（首单词首字母小写）与大驼峰（各单词首字母大写）。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `String`（getter） | 命名转换结果；`isEmpty` 时为 `''`。 |

---

#### `toSnakeCase` / `toSnakeCaseLower` {#string-to-snake}

大蛇形（全大写 + `_`）与小蛇形（全小写 + `_`）。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `String`（getter） | 单词间用 `_` 连接。 |

---

#### `toKebabCase` {#string-to-kebab}

短横线命名（全小写 + `-`）。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `String`（getter） | 单词间用 `-` 连接。 |

---

#### `isValidUrl` {#string-is-valid-url}

用内置正则粗略判断是否为 URL（含可选 `http`/`https` 前缀）。

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `bool`（getter） | 匹配则 `true`。 |

---

## 字符串空安全 {#string-null-safe}

`FastStringNullSafeExtension on String?`。

### 基础使用示例 {#string-null-safe-example}

```dart
String? name;
name.nullSafeOrEmpty;           // ''
name.nullSafe(value: 'guest');  // guest
name.isNullOrEmpty;             // true

name.nullSafeThrow(); // null 时抛出 ArgumentError（可传 message / exception）
```

### 完整 API 参考 {#string-null-safe-api}

---

#### `nullSafeOrEmpty` {#string-null-safe-or-empty}

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `String`（getter） | `null` → `''`。 |

---

#### `nullSafe` {#string-null-safe-null-safe}

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `value` | `String?` | 否 | 为 `null` 时的备用值；仍为空则走 `nullSafeOrEmpty`。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| — | `String` | 非空则用 `this`，否则用 `value` 再兜底。 |

---

#### `nullSafeThrow` {#string-null-safe-throw}

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `exception` | `Exception?` | 否 | 自定义异常；默认 `ArgumentError`。 |
| `message` | `String?` | 否 | 默认错误文案（无 `exception` 时）。 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| — | `String` | 非空时返回自身。 |

---

#### `isNullOrEmpty` {#string-is-null-or-empty}

|  | 类型 | 说明 |
| --- | --- | --- |
| 返回值 | `bool`（getter） | `null` 或 `''` 为 `true`。 |

---

## 布尔空安全 {#bool-null-safe}

`FastBoolNullSafeExtension on bool?`。

### 基础使用示例 {#bool-null-safe-example}

```dart
bool? flag;
flag.nullSafeOrFalse;  // false
flag.nullSafeOrTrue;   // true
flag.nullSafe(value: true); // true
```

### 完整 API 参考 {#bool-null-safe-api}

| API | 返回值 | 说明 |
| --- | --- | --- |
| `nullSafeOrFalse` | `bool` | `null` → `false` |
| `nullSafeOrTrue` | `bool` | `null` → `true` |
| `nullSafe({bool? value})` | `bool` | 用 `value` 兜底，再经 `nullSafeOrFalse` |
| `nullSafeThrow({Exception? exception})` | `bool` | `null` 时抛错，否则返回自身 |

---

## 数值工具 {#num-utils}

`FastNumExtension on num`（非空数值）。

### 基础使用示例 {#num-utils-example}

```dart
5.isBetween(1, 10);   // true（边界含端点，参数顺序无关）
10.isDivisibleBy(2);  // true
10.isDivisibleBy(0);  // false（除数为 0）
```

### 完整 API 参考 {#num-utils-api}

---

#### `isBetween` {#num-is-between}

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `betweenOne` | `num` | 是 | 区间一端 |
| `betweenTwo` | `num` | 是 | 区间另一端 |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| — | `bool` | `this` 落在闭区间内 |

---

#### `isDivisibleBy` {#num-is-divisible-by}

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `divisor` | `num` | 是 | 除数；为 `0` 时返回 `false` |

| 返回值 | 类型 | 说明 |
| --- | --- | --- |
| — | `bool` | 能否整除 |

---

## 数值空安全 {#num-null-safe}

`int?`、`double?`、`num?` 分别提供对应扩展；API 形态一致，默认值分别为 `0`、`0.0`、`0`。

### 基础使用示例 {#num-null-safe-example}

```dart
int? count;
count.nullSafeOrEmpty;        // 0
count.nullSafe(value: 42);    // 42
count.nullSafeThrow();        // null → ArgumentError

double? rate;
rate.nullSafeOrEmpty;         // 0.0
```

### 完整 API 参考 {#num-null-safe-api}

各类型均包含：

| API | 说明 |
| --- | --- |
| `nullSafeOrEmpty` | `null` 时返回该类型零值 |
| `nullSafe({T? value})` | 可选默认值后再零值兜底 |
| `nullSafeThrow({Exception? exception})` | 非空断言 |

类型对应：`FastIntNullSafeExtension`、`FastDoubleNullSafeExtension`、`FastNumNullSafeExtension`。
