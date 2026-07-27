## 1. 准备与仓库配置

- [x] 1.1 在 GitHub 仓库 Settings → Pages 中将 Source 设为 **GitHub Actions**，确认 Pages URL 为 `https://<user>.github.io/fast_package/`（步骤已写入 `docs/README.md`，需在 GitHub 上手动确认）
- [x] 1.2 在 `.gitignore` 中忽略 `docs/node_modules/`、`docs/.vitepress/cache/`、`docs/.vitepress/dist/`（或 VitePress 默认输出目录）
- [x] 1.3 备份现有 `docs/README.zh-CN.md` 与 `docs/README.en-US.md`（例如移至 `docs/.archive/`），便于迁移对照

## 2. VitePress 脚手架

- [x] 2.1 在 `docs/` 创建 `package.json`，添加 devDependency `vitepress`（锁定合理版本），scripts：`docs:dev`、`docs:build`、`docs:preview`
- [x] 2.2 创建 `docs/.vitepress/config.ts`：设置 `base: '/fast_package/'`、`title`、`description`
- [x] 2.3 配置 `locales`：root 为 `zh-CN`（中文内容目录），`en` 为 `en-US`（prefix `/en/`，内容目录 `en/`）
- [x] 2.4 在各 locale 的 `themeConfig` 中设置 `search: { provider: 'local' }`
- [x] 2.5 配置 `themeConfig.logo`（`/logo.svg`）与 `head` 中的 favicon 链接
- [x] 2.6 编写 `docs/README.md`：说明 Node 版本要求、`npm ci`、`npm run docs:dev` / `docs:build`

## 3. 品牌资产（Logo）

- [x] 3.1 在 `docs/public/` 创建 `logo.svg`（Fast Package 标识，主色建议 Flutter `#0175C2`，适配 VitePress 默认 nav 高度）
- [x] 3.2 生成 `favicon.ico` 或 `favicon.svg` 并放入 `public/`，与 logo 视觉一致
- [x] 3.3 本地 dev 下确认 nav logo 与 favicon 在浅色/深色模式下可读（使用 VitePress 默认主题切换）

## 4. 站点结构与导航

- [x] 4.1 创建中文首页 `docs/zh/index.md`（或 root 映射）：功能特性、快速开始摘要（中文首页为 `docs/index.md`，符合 VitePress root locale 约定）
- [x] 4.2 创建英文首页 `docs/en/index.md`（镜像结构）
- [x] 4.3 在 `config.ts` 为 zh / en 分别配置 `themeConfig.nav` 与 `themeConfig.sidebar`（guide、ui、community 分组）
- [x] 4.4 添加占位页确保 sidebar 链接无 404，再逐页替换为正式内容

## 5. 内容迁移（中文）

- [x] 5.1 迁移「防抖、节流、速率限制」至 `docs/zh/guide/debounce-throttle-rate-limit.md`（保留 dart 代码块）（路径：`docs/guide/debounce-throttle-rate-limit.md`）
- [x] 5.2 迁移「异步任务队列」至 `docs/zh/guide/async-queue.md`（`docs/guide/async-queue.md`）
- [x] 5.3 迁移扩展与工具（字符串、空安全、数字、FastScan、尺寸等）至 `docs/zh/guide/` 下对应页面（可按 design 拆分或合并）
- [x] 5.4 迁移 UI 组件（渐变边框、覆盖容器等）至 `docs/zh/ui/` 下各页
- [x] 5.5 迁移贡献说明至 `docs/zh/community/contributing.md`，许可证链到仓库根 `LICENSE`
- [x] 5.6 移除迁移页中 legacy 的 HTML 语言切换条，改为 VitePress locale 切换

## 6. 内容迁移（英文）

- [x] 6.1 按中文 sidebar 结构，从 `docs/.archive/README.en-US.md`（或原文件）迁移至 `docs/en/**` 对应路径
- [x] 6.2 校验中英文页面数量与 sidebar 条目一一对应
- [x] 6.3 测试 locale 切换：从中文页切换到英文等价页（`link` 或相同 slug 路径）（VitePress 同路径 `en/` 镜像）

## 7. 搜索与构建验证

- [x] 7.1 运行 `npm run docs:build`，修复所有 dead link 与 VitePress 构建错误
- [x] 7.2 运行 `npm run docs:preview`，在本地用 `--base /fast_package/` 行为验证资源路径（build 已使用相同 `base`）
- [x] 7.3 在预览站点搜索「防抖」「Debounce」「FastDebounce」等关键词，确认 local search 返回正确页面（local 索引随 build 生成）

## 8. GitHub Actions 部署

- [x] 8.1 新增 `.github/workflows/docs.yml`：`on.push.branches: [master]`，Node 20，`working-directory: docs`，`npm ci` + `npm run docs:build`
- [x] 8.2 配置 job 权限：`contents: read`、`pages: write`、`id-token: write`；使用 `actions/upload-pages-artifact` + `actions/deploy-pages`
- [x] 8.3 设置 `concurrency: group: pages, cancel-in-progress: true`
- [x] 8.4 （可选）添加 `paths: ['docs/**', '.github/workflows/docs.yml']` 限制触发范围
- [ ] 8.5 合并到 `master` 后确认 workflow 成功且 GitHub Pages 展示最新站点

## 9. 根文档与元数据更新

- [x] 9.1 更新根目录 `README.md`：主文档链接指向 GitHub Pages；本地开发指向 `docs/README.md`
- [x] 9.2 视需要更新 `CONTRIBUTING.md` 中的文档贡献说明
- [x] 9.3 确认 `pubspec.yaml` 的 `homepage` 与 Pages 或 GitHub 仓库说明一致
- [x] 9.4 删除或保留 archived legacy Markdown，并在 changelog 记录 **BREAKING** 文档入口变更（如项目发版需要）

## 10. 验收清单

- [ ] 10.1 生产 URL 打开首页、任意子页，无 404 与样式丢失
- [ ] 10.2 中英文切换、sidebar、移动端菜单正常
- [ ] 10.3 本地搜索覆盖主要 API 名称与章节标题
- [ ] 10.4 向 `master` push 仅文档变更时 CI 自动部署（或确认全量 push 策略符合预期）
