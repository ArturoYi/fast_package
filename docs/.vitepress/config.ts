import { defineConfig } from 'vitepress'

const sharedHead = [
  ['link', { rel: 'icon', href: '/favicon.svg', type: 'image/svg+xml' }],
]

const sharedLogo = {
  src: '/logo.svg',
  alt: 'Fast Package',
}

function sidebarZh() {
  return [
    {
      text: '指南',
      items: [
        { text: '快速开始', link: '/guide/getting-started' },
        { text: '防抖、节流、速率限制', link: '/guide/debounce-throttle-rate-limit' },
        { text: '异步任务队列', link: '/guide/async-queue' },
        { text: '扩展函数', link: '/guide/extensions' },
        { text: '尺寸计算工具', link: '/guide/scan-size' },
      ],
    },
    {
      text: 'UI 组件',
      items: [
        { text: '渐变边框', link: '/ui/gradient-border' },
        { text: '覆盖容器', link: '/ui/cover-box' },
      ],
    },
    {
      text: '社区',
      items: [
        { text: '贡献', link: '/community/contributing' },
        { text: '许可证', link: '/community/license' },
      ],
    },
  ]
}

function sidebarEn() {
  return [
    {
      text: 'Guide',
      items: [
        { text: 'Getting Started', link: '/en/guide/getting-started' },
        { text: 'Debounce, Throttle, Rate Limit', link: '/en/guide/debounce-throttle-rate-limit' },
        { text: 'Async Task Queue', link: '/en/guide/async-queue' },
        { text: 'Extensions', link: '/en/guide/extensions' },
        { text: 'Size Calculation Tools', link: '/en/guide/scan-size' },
      ],
    },
    {
      text: 'UI Components',
      items: [
        { text: 'Gradient Borders', link: '/en/ui/gradient-border' },
        { text: 'Cover Box', link: '/en/ui/cover-box' },
      ],
    },
    {
      text: 'Community',
      items: [
        { text: 'Contributing', link: '/en/community/contributing' },
        { text: 'License', link: '/en/community/license' },
      ],
    },
  ]
}

export default defineConfig({
  base: '/fast_package/',
  title: 'Fast Package',
  description: 'Flutter 快速开发工具包文档',
  head: sharedHead,
  locales: {
    root: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/',
      themeConfig: {
        logo: sharedLogo,
        search: { provider: 'local' },
        nav: [
          { text: '指南', link: '/guide/getting-started', activeMatch: '/guide/' },
          { text: 'UI 组件', link: '/ui/gradient-border', activeMatch: '/ui/' },
          { text: 'GitHub', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        sidebar: sidebarZh(),
        socialLinks: [
          { icon: 'github', link: 'https://github.com/ArturoYi/fast_package' },
        ],
      },
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      themeConfig: {
        logo: sharedLogo,
        search: { provider: 'local' },
        nav: [
          { text: 'Guide', link: '/en/guide/getting-started', activeMatch: '/en/guide/' },
          { text: 'UI', link: '/en/ui/gradient-border', activeMatch: '/en/ui/' },
          { text: 'GitHub', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        sidebar: sidebarEn(),
        socialLinks: [
          { icon: 'github', link: 'https://github.com/ArturoYi/fast_package' },
        ],
      },
    },
  },
})
