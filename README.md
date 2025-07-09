# Fast Package

[![pub package](https://img.shields.io/pub/v/fast_package.svg)](https://pub.dev/packages/fast_package)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

一个基于纯 Flutter 实现的快速开发工具包，提供常用的工具方法、扩展函数和 UI 组件。

A fast development toolkit based on pure Flutter, providing common utility methods, extension functions, and UI components.

## 📋 文档说明 / Documentation

本项目提供了多语言版本的README文档：

This project provides multi-language README documentation:

### 可用语言 / Available Languages

- 🇨🇳 [中文文档](docs/README.zh-CN.md) - 完整的中文版本
- 🇺🇸 [English Documentation](docs/README.en-US.md) - Complete English version

### 如何切换语言 / How to Switch Languages

1. 在项目根目录的 `README.md` 文件中，点击顶部的语言链接
2. 或者直接访问 `docs/` 目录下的对应语言文件

3. In the project root `README.md` file, click the language links at the top
4. Or directly access the corresponding language file in the `docs/` directory

### 文档结构 / Documentation Structure

```markdown
docs/
├── README.zh-CN.md    # 中文文档 / Chinese documentation
└── README.en-US.md    # 英文文档 / English documentation
```

### 贡献 / Contributing

如果您发现任何翻译错误或想要改进文档，请提交 Issue 或 Pull Request。

If you find any translation errors or want to improve the documentation, please submit an Issue or Pull Request.

## 📋 目录 / Table of Contents

- [功能特性 / Features](#功能特性--features)
- [快速开始 / Quick Start](#快速开始--quick-start)
- [使用教程 / Usage Tutorials](#使用教程--usage-tutorials)
- [贡献 / Contributing](#贡献--contributing)
- [许可证 / License](#许可证--license)

## 🚀 功能特性 / Features

- **🔄 异步控制**: 防抖、节流、速率限制功能
- **📋 任务队列**: 顺序执行异步任务的队列管理
- **🔧 扩展函数**: 丰富的字符串、数字、空安全扩展
- **📐 尺寸工具**: 智能的尺寸计算和适配工具
- **🎨 UI 组件**: 实用的 UI 组件和装饰器
- **⚡ 高性能**: 基于纯 Flutter 实现，无额外依赖
- **🛡️ 类型安全**: 完整的空安全支持

## 🏃‍♂️ 快速开始 / Quick Start

### 安装 / Installation

请在安装前检查最新版本。如果新版本有任何问题，请使用以前的版本。

Please check the latest version before installation. If there are any issues with the new version, please use the previous version.

```yaml
dependencies:
  flutter:
    sdk: flutter
  # add fast_package
  fast_package: ^{latest version}
```

### 导入 / Import

```dart
import 'package:fast_package/fast_package.dart';
```

## 📚 使用教程 / Usage Tutorials

详细的使用教程和示例代码请查看以下语言版本的文档：

For detailed usage tutorials and example code, please check the following language versions:

### 支持的语言教程文档 / Supported Language Tutorials

- 🇨🇳 **[中文教程](docs/README.zh-CN.md)** - 完整的中文使用教程和示例
- 🇺🇸 **[English Tutorial](docs/README.en-US.md)** - Complete English usage tutorial and examples

### 教程内容包含 / Tutorial Contents Include

- 🔄 **异步控制**: 防抖、节流、速率限制功能
- 📋 **任务队列**: 顺序执行异步任务的队列管理
- 🔧 **扩展函数**: 丰富的字符串、数字、空安全扩展
- 📐 **尺寸工具**: 智能的尺寸计算和适配工具
- 🎨 **UI 组件**: 实用的 UI 组件和装饰器

- 🔄 **Async Control**: Debounce, throttle, and rate limit functionality
- 📋 **Task Queue**: Sequential execution of asynchronous task queue management
- 🔧 **Extension Functions**: Rich string, number, and null safety extensions
- 📐 **Size Tools**: Intelligent size calculation and adaptation tools
- 🎨 **UI Components**: Practical UI components and decorators

## 🤝 贡献 / Contributing

我们欢迎所有形式的贡献！如果你有更好的主意或发现了问题，请：

We welcome all forms of contributions! If you have better ideas or find issues, please:

1. 🐛 报告 Bug / Report bugs
2. 💡 提出新功能建议 / Suggest new features
3. 📝 改进文档 / Improve documentation
4. 🔧 提交代码 / Submit code

如果你有更好的主意，请告诉我。

If you have better ideas, please let me know.

## 📄 许可证 / License

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
