## Why

当前文档以两份独立 Markdown（`docs/README.zh-CN.md`、`docs/README.en-US.md`）维护，缺少站点导航、站内搜索与统一发布渠道，读者体验与维护成本都不理想。采用 VitePress 重建文档站点，并接入 GitHub Pages 自动部署，可在保持中英双语内容的同时提供现代化阅读体验与可发现的 API/教程结构。

## What Changes

- 在仓库中新增 VitePress 文档工程（建议位于 `docs/` 或 `docs-site/`，具体目录由 design 确定），替换「仅 Markdown 文件」的文档形态。
- 将现有 `docs/README.zh-CN.md` 与 `docs/README.en-US.md` 的内容迁移为 VitePress 多页面结构（按功能模块拆分，而非单页超长文档）。
- 配置 VitePress 国际化（中文为默认或并列 locale，英文为 `en-US`），语言切换与独立侧边栏/导航。
- 启用浏览器内本地全文搜索：`themeConfig.search.provider: 'local'`（MiniSearch）。
- 使用 VitePress 默认主题与样式体系，并为本项目定制 logo（导航栏与 favicon）。
- 新增 GitHub Actions workflow：推送到 `master` 时构建文档并部署到 GitHub Pages。
- 更新根目录 `README.md` 中的文档链接，指向 GitHub Pages 或本地开发说明。
- **BREAKING**：原 `docs/README.zh-CN.md` / `docs/README.en-US.md` 作为唯一文档入口的方式将被弃用（可保留为重定向说明或删除，由实现阶段在 tasks 中明确）。

## Capabilities

### New Capabilities

- `vitepress-docs-site`: VitePress 文档站点结构、中英 i18n、本地搜索、主题与项目 logo 品牌化。
- `docs-github-pages-deploy`: 基于 `master` 分支 push 的文档构建与 GitHub Pages 发布流水线及仓库 Pages 配置要求。

### Modified Capabilities

（无：`openspec/specs/` 下尚无既有 capability spec。）

## Impact

- **目录**：`docs/`（或新子目录）、`.vitepress/`、`package.json`（文档专用 Node 依赖）、静态资源（logo、favicon）。
- **CI**：`.github/workflows/` 新增 docs 部署 workflow；可能与现有 `test.yml`、`publish.yml` 并行，需明确 path filter 或全量触发策略。
- **依赖**：Node.js、VitePress、MiniSearch（随 VitePress local search 引入）；Flutter/Dart 包本身无运行时依赖变化。
- **对外链接**：`pubspec.yaml` 的 `homepage`、README 文档链接需与 GitHub Pages URL 对齐。
- **维护流程**：文档贡献者需了解 VitePress 开发与 `npm run docs:dev` / `docs:build` 类脚本（具体命令在 design/tasks 中定义）。
