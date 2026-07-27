# 文档站点（VitePress）

本目录为 [Fast Package](https://github.com/ArturoYi/fast_package) 的 VitePress 文档工程。

## 环境要求

- Node.js **20** 或更高版本
- npm 9+

## 本地开发

```bash
cd docs
npm ci
npm run docs:dev
```

默认开发服务器地址为 `http://localhost:5173/fast_package/`（与 GitHub Pages 的 `base` 一致）。

## 构建与预览

```bash
npm run docs:build
npm run docs:preview
```

## GitHub Pages 部署

1. 在 GitHub 仓库 **Settings → Pages** 中，将 **Build and deployment → Source** 设为 **GitHub Actions**。
2. 向 `master` 分支推送包含 `docs/` 的变更后，`.github/workflows/docs.yml` 会自动构建并部署。
3. 线上地址：<https://arturoyi.github.io/fast_package/>

## 多语言

- 简体中文：站点根路径 `/`
- English：`/en/`

语言切换使用 VitePress 内置 locale 切换器。站内搜索为本地索引（MiniSearch），配置见 `.vitepress/config.ts` 中的 `themeConfig.search.provider: 'local'`。

## 旧版 Markdown

迁移前的单文件文档备份在 `.archive/README.zh-CN.md` 与 `.archive/README.en-US.md`。
