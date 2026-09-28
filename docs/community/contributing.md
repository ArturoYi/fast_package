---
title: 贡献
outline: [2, 3]
---

## 贡献 {#contributing}

我们欢迎所有形式的贡献。下面三类请开 [GitHub Issue](https://github.com/ArturoYi/fast_package/issues)；改代码请提 Pull Request。

开 Issue 前先搜一下 [已有 Issue](https://github.com/ArturoYi/fast_package/issues)。别贴密钥、证书或业务数据。

### 报告 Bug {#report-bug}

API 行为不对、组件渲染异常，或文档、示例和实现不符时，用 [Bug 模板](https://github.com/ArturoYi/fast_package/issues/new?template=bug_report.yml) 开 Issue。打开后 GitHub 会带上下面这些字段，按表填写即可。

**标题：** `[Bug]: ` 加一句话。例如：`[Bug]: FastToast 在键盘弹起后没有跟着上移`

| 字段 | 写什么 |
| --- | --- |
| 一句话 | 发生了什么 |
| 期望 | 你认为正确的行为 |
| 实际 | 现在实际发生了什么 |
| 怎么复现 | 越小越好。写清调用和操作步骤 |
| 最小代码 | 精简后的调用或 Widget。文档问题可写页面路径 |
| 相关模块 | 从模板里选，例如 Toast、Refresh、文档 / 示例 |
| Fast Package 版本或 commit | `pubspec.yaml` 里的版本，或出问题的 commit |
| Flutter / Dart 版本 | `flutter --version` 的输出 |
| 平台 | Android、iOS、Web、macOS、Windows、Linux，或多平台 / 不确定 |
| 日志或截图说明 | 可选。异常栈、断言信息，或描述截图里看到的现象 |

表单定义在 [`.github/ISSUE_TEMPLATE/bug_report.yml`](https://github.com/ArturoYi/fast_package/blob/master/.github/ISSUE_TEMPLATE/bug_report.yml)。

### 提出新功能建议 {#feature-request}

新工具、扩展或轻量 UI，用 [功能模板](https://github.com/ArturoYi/fast_package/issues/new?template=feature_request.yml) 开 Issue。说清楚要解决什么，以及期望的 API 或交互长什么样。优先稳住现有能力，再考虑扩展；尽量不引入第三方依赖。

**标题：** `[Feature]: ` 加一句话。

| 字段 | 写什么 |
| --- | --- |
| 要解决什么 | 日常开发里重复出现、或现有模块覆盖不到的痛点 |
| 期望长什么样 | API、组件交互，或希望补上的行为 |
| 方向 | 异步控制、扩展与工具、UI 组件，或其他 |
| 现在怎么做 | 可选。本地临时写法，或是否考虑过现有模块 |

### 改进文档 {#improve-docs}

错字、过时说明、缺示例，或示例和正文对不上，用 [文档模板](https://github.com/ArturoYi/fast_package/issues/new?template=docs.yml) 开 Issue。文档写错、和代码行为不符时，改用上面的 [Bug 模板](https://github.com/ArturoYi/fast_package/issues/new?template=bug_report.yml)，相关模块选「文档 / 示例」。

能直接改的也可以提 Pull Request。文档在 `docs/`，本地预览见 [docs/README.md](https://github.com/ArturoYi/fast_package/blob/master/docs/README.md)。

**标题：** `[Docs]: ` 加一句话。例如：`[Docs]: Toast 页缺少键盘避让说明`

| 字段 | 写什么 |
| --- | --- |
| 页面 | 文档路径或链接，并注明中文或 English |
| 问题 | 哪里不对、缺了什么，或哪段不好懂 |
| 建议 | 期望怎么改。没有完整改法也可以，写清卡住的地方 |

### 提交代码 {#submit-code}

修 Bug、做功能或改文档，都可以提 Pull Request。提交前在本地运行 `flutter test` 与 `flutter analyze`。文档改动在 `docs/` 里执行 `npm ci`，再用 `npm run docs:dev` 或 `npm run docs:build` 看一遍。更多说明见 [CONTRIBUTING.md](https://github.com/ArturoYi/fast_package/blob/master/CONTRIBUTING.md)。
