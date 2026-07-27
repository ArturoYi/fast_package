## Context

`fast_package` 是 Flutter 工具包，当前文档为 `docs/README.zh-CN.md` 与 `docs/README.en-US.md` 两个超长 Markdown，通过根 `README.md` 链入。无站点导航、无搜索、无 CI 发布。目标是用 VitePress 重建文档，中英双语 + 本地搜索 + GitHub Pages 自动部署，视觉遵循 VitePress 默认主题并增加项目 logo。

仓库已有 GitHub Actions：`test.yml`（Flutter 测试）、`publish.yml`（pub 发布）。文档构建应独立 workflow，避免与 Flutter job 混用。

## Goals / Non-Goals

**Goals:**

- 可本地开发与 CI 构建的 VitePress 站点，内容从现有双语文档迁移并模块化。
- `themeConfig.search.provider: 'local'` 启用 MiniSearch 模糊全文搜索。
- VitePress 内置 i18n（`zh-CN` + `en-US`），各 locale 独立 `themeConfig` / sidebar。
- 默认主题 + 项目 logo（nav + favicon），不引入与 VitePress 冲突的 UI 框架。
- `master` push 触发构建并部署 GitHub Pages；`base` 与 Pages URL 一致。

**Non-Goals:**

- 文档内容的重大重写或 API 变更（迁移为主，措辞微调可接受）。
- Algolia DocSearch 等外部搜索服务。
- 在 pub.dev 托管文档（仍可用 homepage 链到 GitHub Pages）。
- 为 example app 编写独立 VitePress 章节以外的全新教程体系（除非迁移时发现缺口）。

## Decisions

### D1: 文档工程目录布局

**选择：** 将 VitePress 根目录设为 `docs/`，结构如下：

```text
docs/
├── .vitepress/
│   ├── config.ts          # 共享配置 + locales
│   └── theme/             # 可选：最小 custom theme 扩展（通常仅 default）
├── public/
│   ├── logo.svg           # 导航 logo
│   └── favicon.ico        # 或 favicon.svg
├── zh/
│   ├── index.md
│   ├── guide/
│   └── ...
├── en/
│   ├── index.md
│   └── ...                # 与 zh 镜像结构
├── package.json
└── README.md              # 贡献者：如何 dev/build
```

**理由：** 与现有 `docs/` 路径一致，根 README 已指向 `docs/`；VitePress 官方推荐 `docs` 作为内容根。旧文件 `README.zh-CN.md` / `README.en-US.md` 迁移完成后移至 `docs/.archive/` 或删除，并在 `docs/README.md` 说明。

**备选：** 根目录 `docs-site/` — 避免与旧 md 冲突，但需改 README 链接，弃用。

### D2: i18n 策略

**选择：** VitePress `locales` 配置：

- `root`：`lang: 'zh-CN'`，中文内容在 `docs/zh/` 或通过 `root` 指向中文（二选一；推荐 **root = zh-CN**，英文为 `/en/` prefix）。
- `en`：`lang: 'en-US'`，label `English`，内容在 `docs/en/`。

各 locale 配置独立 `themeConfig.nav` 与 `themeConfig.sidebar`，链接路径带 locale prefix（英文 `/en/guide/...`）。

**理由：** 与现有文件名 `README.zh-CN.md` / `README.en-US.md` 对齐；中文用户为主时可设 root 为中文。

### D3: 本地搜索

**选择：** 在共享或 per-locale `themeConfig` 中设置：

```ts
search: { provider: 'local' }
```

可选：`search.options` 调整中英文分词/详情（使用默认即可，后续再调）。

### D4: Logo 与品牌

**选择：** 生成 **SVG logo**（矢量、深色/浅色背景下可读）：

- 概念：字母 **F** + 闪电/速度线条，配色接近 VitePress 默认 brand（`#3c8772` 或 Flutter 蓝 `#0175C2` 二选一，design 实现时定稿一种主色）。
- `themeConfig.logo: { src: '/logo.svg', alt: 'Fast Package' }`
- `head`: favicon 链到 `/favicon.ico` 或 SVG。

**理由：** 用户要求「样式和主题完全对齐 vitepress」— 不覆盖 VitePress CSS 变量，仅替换 logo 资产。

**实现方式：** 手写 SVG 或使用简单几何图形（无需外部设计工具依赖）；提供 `logo.svg` 与 32px favicon。

### D5: GitHub Pages `base`

**选择：** `base: '/fast_package/'`（与 `pubspec.yaml` `homepage: https://github.com/ArturoYi/fast_package` 的 project site 路径一致）。

若仓库改为 user/org site 或自定义域名，仅改 `base` 与 workflow 环境变量 `DOCS_BASE`.

### D6: CI/CD workflow

**选择：** 新文件 `.github/workflows/docs.yml`：

| 项 | 值 |
|----|-----|
| `on.push.branches` | `[master]` |
| `on.push.paths` | 可选：`docs/**`, `.github/workflows/docs.yml` — 减少无关 push 构建；首版可用全量 push 简化 |
| Node | `20` LTS |
| 步骤 | checkout → setup-node（cache npm）→ `npm ci` in `docs` → `npm run docs:build` → upload-pages-artifact → deploy-pages |
| 权限 | `contents: read`, `pages: write`, `id-token: write` |
| concurrency | `group: pages`, `cancel-in-progress: true` |

**理由：** GitHub 官方 Pages 部署方式；与 Flutter workflow 解耦。

**备选：** `peaceiris/actions-gh-pages` 推 `gh-pages` 分支 — 仍可行，但官方 deploy-pages 更简。

### D7: 内容拆分映射（迁移）

从现有 H2 章节拆页（中英各一套）：

| 原章节 | 建议路径（zh） | 建议路径（en） |
|--------|----------------|----------------|
| 功能特性 + 快速开始 | `zh/index.md` 或 `zh/guide/getting-started.md` | `en/...` |
| 防抖/节流/速率限制 | `zh/guide/debounce-throttle-rate-limit.md` | 镜像 |
| 异步任务队列 | `zh/guide/async-queue.md` | 镜像 |
| 字符串/空安全/数字/尺寸扩展 | `zh/guide/extensions.md`（或按类型拆分） | 镜像 |
| FastScan 等 | `zh/guide/scan.md` | 镜像 |
| UI 组件 | `zh/ui/gradient-border.md`, `zh/ui/overlay.md` 等 | 镜像 |
| 贡献 / 许可证 | `zh/community/contributing.md` + 链到根 LICENSE | 镜像 |

迁移步骤：复制 md 正文 → 去掉顶部 HTML 语言切换条 → 修正内部链接为 VitePress 路由 → 代码块保留 `dart` 高亮。

### D8: Node 脚本命名

**选择：** `docs/package.json` scripts:

- `docs:dev` → `vitepress dev`
- `docs:build` → `vitepress build`
- `docs:preview` → `vitepress preview`

根目录可选 `package.json` 仅做 proxy scripts，或文档贡献者 `cd docs && npm run docs:dev`。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| GitHub Pages `base` 配置错误导致 CSS/路由 404 | 本地 `vitepress build && vitepress preview` 带 `--base` 验证；CI 后 smoke 检查首页 |
| 超长单页拆分为多页后链接失效 | 迁移 checklist；保留 legacy md 短期 archived |
| 中英文页面不同步 | sidebar 结构强制镜像；PR 模板提醒双语文档 |
| `docs/` 同时含 Node 与 Flutter 文档路径混淆 | `docs/README.md` 明确；`.gitignore` 忽略 `docs/node_modules` |
| master 每次 push 都构建 docs（无 path filter） | 后续加 `paths` 过滤 |

## Migration Plan

### 阶段 0：准备（约 0.5 天）

1. 确认 GitHub 仓库 Settings → Pages → Source = **GitHub Actions**。
2. 记录目标 URL：`https://arturoyi.github.io/fast_package/`（大小写以 GitHub 为准）。

### 阶段 1：脚手架（约 0.5 天）

1. 在 `docs/` 初始化 `package.json`，安装 `vitepress`（devDependency）。
2. 添加 `.vitepress/config.ts`：`base`, `locales`, `themeConfig.logo`, `search.provider: 'local'`, `head` favicon。
3. 创建 `public/logo.svg`、favicon。
4. 占位 `zh/index.md`、`en/index.md` 与最小 sidebar。
5. 验证 `npm run docs:dev` 与 `docs:build`。

### 阶段 2：内容迁移（约 1–2 天）

1. 按 D7 表拆分 `README.zh-CN.md` → `docs/zh/**`。
2. 同样拆分 `README.en-US.md` → `docs/en/**`。
3. 统一 frontmatter（`title`, `description`）便于 SEO 与搜索 snippet。
4. 归档或删除 legacy `docs/README.*.md`；更新根 `README.md` 文档链接。

### 阶段 3：CI/CD（约 0.5 天）

1. 新增 `.github/workflows/docs.yml`（见 D6）。
2. 合并到 `master` 后验证 Actions 绿勾与 Pages 更新。
3. 可选：在 workflow 中加 `paths` 仅 docs 变更时运行。

### 阶段 4：收尾（约 0.25 天）

1. `pubspec.yaml` / README badge 链到 Pages（如需要）。
2. CONTRIBUTING 增加「文档修改 → cd docs → dev/build」说明。
3. 手动测试：语言切换、搜索关键词（如「防抖」「Debounce」）、移动端导航。

### 回滚

- 关闭 `docs.yml` workflow 或禁用 Pages；恢复 legacy Markdown 链接于根 README。
- GitHub Pages 保留上一成功 deploy 的 artifact（concurrency 下可 redeploy 上一 commit）。

## Open Questions

1. 默认 locale 是否必须为中文 root，还是英文与中文并列 `/zh/`、`/en/`（无 root 内容）？**建议：** 中文 root，英文 `/en/`。
2. CI 是否仅在 `docs/**` 变更时触发？**建议：** 首版全 master push，稳定后加 paths。
3. Logo 主色选 Flutter 蓝还是 VitePress 绿？**建议：** Flutter `#0175C2` 与包生态一致。
