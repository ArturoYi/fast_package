---
title: Contributing
outline: [2, 3]
---

## Contributing {#contributing}

We welcome contributions of all kinds. For the three cases below, open a [GitHub Issue](https://github.com/ArturoYi/fast_package/issues). For code changes, open a pull request.

Search [existing issues](https://github.com/ArturoYi/fast_package/issues) first. Do not paste secrets, certificates, or private business data.

The issue forms are in Chinese. The tables below map each field.

### Report bugs {#report-bug}

When an API behaves incorrectly, a widget renders wrong, or the docs or examples disagree with the implementation, open an issue with the [bug report form](https://github.com/ArturoYi/fast_package/issues/new?template=bug_report.yml).

**Title:** `[Bug]: ` plus one sentence. Example: `[Bug]: FastToast does not move up when the keyboard opens`

| Field | What to write |
| --- | --- |
| 一句话 | What happened, in one sentence |
| 期望 | The behavior you expected |
| 实际 | What actually happened |
| 怎么复现 | The smallest steps. Include the call and what you did |
| 最小代码 | A reduced call or widget. For a docs issue, the page path is enough |
| 相关模块 | Pick one in the form, such as Toast, Refresh, or 文档 / 示例 |
| Fast Package 版本或 commit | The version in `pubspec.yaml`, or the commit where it failed |
| Flutter / Dart 版本 | Output of `flutter --version` |
| 平台 | Android, iOS, Web, macOS, Windows, Linux, or 多平台 / 不确定 |
| 日志或截图说明 | Optional. A stack trace, assertion, or what the screenshot shows |

The form lives at [`.github/ISSUE_TEMPLATE/bug_report.yml`](https://github.com/ArturoYi/fast_package/blob/master/.github/ISSUE_TEMPLATE/bug_report.yml).

### Propose features {#feature-request}

For a new utility, extension, or lightweight UI, open an issue with the [feature form](https://github.com/ArturoYi/fast_package/issues/new?template=feature_request.yml). Say what problem it solves and what the API or interaction should look like. Stabilize what already exists before expanding it, and avoid new third-party dependencies.

**Title:** `[Feature]: ` plus one sentence.

| Field | What to write |
| --- | --- |
| 要解决什么 | A pain point that keeps showing up, or something current modules do not cover |
| 期望长什么样 | The API, interaction, or behavior you want |
| 方向 | Async control, extensions and tools, UI, or other |
| 现在怎么做 | Optional. A local workaround, or whether you already looked at an existing module |

### Improve documentation {#improve-docs}

For typos, outdated text, missing examples, or an example that does not match the page, open an issue with the [docs form](https://github.com/ArturoYi/fast_package/issues/new?template=docs.yml). If the docs are wrong relative to the code, use the [bug report form](https://github.com/ArturoYi/fast_package/issues/new?template=bug_report.yml) and set 相关模块 to「文档 / 示例」.

A pull request is also fine. Docs live in `docs/`. Local preview is described in [docs/README.md](https://github.com/ArturoYi/fast_package/blob/master/docs/README.md).

**Title:** `[Docs]: ` plus one sentence. Example: `[Docs]: Toast page does not mention keyboard avoidance`

| Field | What to write |
| --- | --- |
| 页面 | Doc path or URL, and whether it is 中文 or English |
| 问题 | What is wrong, missing, or hard to follow |
| 建议 | How you would change it. A partial note is enough if you are stuck |

### Submit code {#submit-code}

Bug fixes, features, and doc edits can all be pull requests. Run `flutter test` and `flutter analyze` locally before you submit. For doc changes, run `npm ci` in `docs/`, then `npm run docs:dev` or `npm run docs:build`. See [CONTRIBUTING.md](https://github.com/ArturoYi/fast_package/blob/master/CONTRIBUTING.md).
