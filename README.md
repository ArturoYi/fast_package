<p align="center">
  <a href="https://arturoyi.github.io/fast_package/en/">
    <img src="docs/public/logo.svg" alt="Fast Package" width="128" />
  </a>
</p>

<h1 align="center">Fast Package</h1>

<p align="center">
  A lightweight Flutter development toolkit · Flutter SDK only
</p>

<p align="center">
  <a href="README.md">English</a>
  ·
  <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  <a href="https://github.com/ArturoYi/fast_package/stargazers">
    <img src="https://img.shields.io/github/stars/ArturoYi/fast_package?style=flat&logo=github&label=stars" alt="GitHub stars" />
  </a>
  <a href="https://pub.dev/packages/fast_package">
    <img src="https://img.shields.io/pub/v/fast_package.svg?label=pub.dev&logo=dart" alt="pub.dev" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-BSD--3--Clause-blue.svg" alt="BSD 3-Clause License" />
  </a>
</p>

<p align="center">
  <strong>
    <a href="https://arturoyi.github.io/fast_package/en/">Docs</a>
    ·
    <a href="https://arturoyi.github.io/fast_package/">中文文档</a>
    ·
    <a href="https://github.com/ArturoYi/fast_package/issues">Issues</a>
  </strong>
</p>

---

## Why this package

Across Flutter projects, the same small utilities keep getting rewritten: debounce and throttle, ordered queues, string extensions, layout size conversion…  
Pulling in a pile of third-party packages often means version conflicts and extra size, while many of these pieces can be written clearly with Flutter alone.

**Fast Package** is intentionally small: everyday utilities gathered into a **zero extra-dependency** package. APIs stay straightforward, the source is readable, and you can take what you need or fork it—without another “do-everything” framework.

---

## How it grew

It started as copy-pasted helpers between projects. Maintenance and consistency pushed it into a standalone open-source package.  
Features landed as they were needed: first the pain points, then docs and tests, then a VitePress site so Chinese and English docs stay searchable and maintainable.

The pace stays **small and verifiable**: each module should have a clear purpose and boundary, not a kitchen-sink API.

---

## Planning and how we build

| Area | Approach |
| --- | --- |
| **Features** | Keep adding high-frequency utilities and lightweight UI. Stabilize existing APIs before expanding. |
| **Implementation** | Business logic and public APIs are **written by hand** so they stay readable, reviewable, and predictable. |
| **AI** | Used for **docs, examples, and test help**—not as a substitute for core design or review of critical paths. |
| **Docs** | Install, API, and examples live on the **[docs site](https://arturoyi.github.io/fast_package/en/)**. This README is project context only. |

---

## Contributing and license

Issues, PRs, and docs improvements are welcome.

- **How to contribute:** [CONTRIBUTING.md](CONTRIBUTING.md) · [Docs · Contributing](https://arturoyi.github.io/fast_package/en/community/contributing.html)
- **License:** [BSD 3-Clause](LICENSE)

If this package helps you, a **Star** on GitHub or feedback on [pub.dev](https://pub.dev/packages/fast_package) is appreciated.
