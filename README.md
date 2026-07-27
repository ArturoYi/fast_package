<p align="center">
  <a href="https://arturoyi.github.io/fast_package/">
    <img src="docs/public/logo.svg" alt="Fast Package" width="128" />
  </a>
</p>

<h1 align="center">Fast Package</h1>

<p align="center">
  轻量的 Flutter 快速开发工具包 · 仅依赖 Flutter SDK
</p>

<p align="center">
  <a href="https://github.com/ArturoYi/fast_package/stargazers">
    <img src="https://img.shields.io/github/stars/ArturoYi/fast_package?style=flat&logo=github&label=stars" alt="GitHub stars" />
  </a>
  <a href="https://pub.dev/packages/fast_package">
    <img src="https://img.shields.io/pub/v/fast_package.svg?label=pub.dev&logo=dart" alt="pub.dev" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License" />
  </a>
</p>

<p align="center">
  <strong>
    <a href="https://arturoyi.github.io/fast_package/">📖 文档</a>
    ·
    <a href="https://arturoyi.github.io/fast_package/en/">English</a>
    ·
    <a href="https://github.com/ArturoYi/fast_package/issues">Issues</a>
  </strong>
</p>

---

## 项目初衷

在多个 Flutter 项目里，总会重复写同一类小工具：防抖节流、队列顺序执行、字符串扩展、布局尺寸换算……  
引一堆第三方包往往带来版本拉扯和体积成本，而很多能力其实用纯 Flutter 就能写得清晰、可控。

**Fast Package** 想做的很单纯：把日常开发里真正用得上的能力收拢成一个**零额外依赖**的包，API 尽量直白，源码可读，方便你按需取用或 fork 改造——而不是再叠一层「万能框架」。

---

## 心路历程

这个项目从「项目间复制粘贴的工具函数」开始，后来在维护成本与一致性之间权衡，决定抽成独立包并开源。  
功能按实际需求一点点长出来：先解决自己遇到的痛点，再补文档与测试，最后把文档迁到 VitePress，方便中英文检索与长期维护。

开源之后，我更希望它保持**小步、可验证**的节奏：每个模块都能讲清楚用途和边界，而不是追求大而全。

---

## 规划与实现方式

| 方向 | 说明 |
| --- | --- |
| **功能规划** | 继续补齐高频工具与轻量 UI 能力；优先保证现有 API 稳定，再考虑扩展。 |
| **核心实现** | 业务逻辑与公共 API **尽量手写**，保持可读、可审查、行为可预期。 |
| **AI 的使用** | AI 主要用于**文档编写、示例整理与测试辅助**；不替代核心设计与关键路径的实现与评审。 |
| **文档** | 安装、API 与示例以 **[在线文档](https://arturoyi.github.io/fast_package/)** 为准，README 只做项目说明。 |

---

## 贡献与许可

欢迎 Issue、PR 与文档改进。

- **贡献方式**：[CONTRIBUTING.md](CONTRIBUTING.md) · [文档站 · 贡献](https://arturoyi.github.io/fast_package/community/contributing.html)  
- **许可证**：[MIT License](LICENSE)

若这个包对你有帮助，欢迎在 GitHub 点个 **Star**，或在 [pub.dev](https://pub.dev/packages/fast_package) 留下使用反馈。
