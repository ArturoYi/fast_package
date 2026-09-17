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

文档首页与顶栏的「在线演示」会跳到 `/example/`（嵌套的 Flutter Web 示例）。该目录不由 VitePress 生成，需要先构建 example 再拷进 `dist`：

```bash
cd ../example
flutter pub get
flutter build web --release --base-href /fast_package/example/

cd ../docs
npm run docs:build
cp -R ../example/build/web .vitepress/dist/example
npm run docs:preview
```

预览地址：

- 文档：<http://localhost:4173/fast_package/>
- 示例：<http://localhost:4173/fast_package/example/>

`docs:dev` 只跑文档站，默认没有 Flutter 产物；要联调演示按钮，按上面步骤用 `docs:preview`。

## GitHub Pages 部署

1. 在 GitHub 仓库 **Settings → Pages** 中，将 **Build and deployment → Source** 设为 **GitHub Actions**。
2. 向 `master` 分支推送包含 `docs/`、`example/` 或 `lib/` 的变更后，`.github/workflows/docs.yml` 会构建 VitePress 与 Flutter Web，并将示例嵌到 `/example/` 后部署。
3. 线上地址：
   - 文档：<https://arturoyi.github.io/fast_package/>
   - 示例：<https://arturoyi.github.io/fast_package/example/>

## 多语言

- 简体中文：站点根路径 `/`
- English：`/en/`

语言切换使用 VitePress 内置 locale 切换器。站内搜索为本地索引（MiniSearch），配置见 `.vitepress/config.ts` 中的 `themeConfig.search.provider: 'local'`。

## 旧版 Markdown

迁移前的单文件文档备份在 `.archive/README.zh-CN.md` 与 `.archive/README.en-US.md`。
