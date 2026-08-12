import { defineConfig, type HeadConfig } from 'vitepress'

const siteBase = '/fast_package/'

/** head 里的绝对路径不会自动加 base，需与 siteBase 一致（见 themeConfig.logo 的自动处理） */
const sharedHead: HeadConfig[] = [
  ['link', { rel: 'icon', href: `${siteBase}favicon.svg`, type: 'image/svg+xml' }],
]

const sharedLogo = {
  src: '/logo.svg',
  alt: 'Fast Package',
  height: 24,
}

/** Must live on root themeConfig — local search plugin ignores locales-only config. */
const sharedSearch = {
  provider: 'local' as const,
  options: {
    locales: {
      root: {
        translations: {
          button: {
            buttonText: '搜索',
            buttonAriaLabel: '搜索文档',
          },
          modal: {
            noResultsText: '未找到结果',
            resetButtonTitle: '清除查询条件',
            backButtonTitle: '返回',
            displayDetails: '显示详细列表',
            footer: {
              selectText: '选择',
              selectKeyAriaLabel: 'Enter 键',
              navigateText: '切换',
              navigateUpKeyAriaLabel: '上箭头',
              navigateDownKeyAriaLabel: '下箭头',
              closeText: '关闭',
              closeKeyAriaLabel: 'Esc 键',
            },
          },
        },
      },
      en: {
        translations: {
          button: {
            buttonText: 'Search',
            buttonAriaLabel: 'Search documentation',
          },
        },
      },
    },
  },
}

const sidebarZhGroups = [
  {
    text: '入门',
    items: [{ text: '快速开始', link: '/guide/getting-started' }],
  },
  {
    text: '异步控制',
    items: [
      {
        text: '防抖、节流、速率限制',
        link: '/features/debounce-throttle-rate-limit',
      },
      { text: '异步任务队列', link: '/features/async-queue' },
    ],
  },
  {
    text: '扩展与工具',
    items: [
      { text: '扩展函数', link: '/features/extensions' },
      { text: '尺寸计算工具', link: '/features/scan-size' },
    ],
  },
  {
    text: 'UI 组件',
    items: [
      { text: '渐变边框', link: '/ui/gradient-border' },
      { text: 'Cover 布局', link: '/ui/cover-box' },
      { text: 'Shimmer 骨架屏', link: '/ui/shimmer' },
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

const sidebarEnGroups = [
  {
    text: 'Getting started',
    items: [{ text: 'Quick Start', link: '/en/guide/getting-started' }],
  },
  {
    text: 'Async control',
    items: [
      {
        text: 'Debounce, Throttle, and Rate Limit',
        link: '/en/features/debounce-throttle-rate-limit',
      },
      { text: 'Async Task Queue', link: '/en/features/async-queue' },
    ],
  },
  {
    text: 'Extensions & tools',
    items: [
      { text: 'Extensions', link: '/en/features/extensions' },
      { text: 'Size Calculation Tools', link: '/en/features/scan-size' },
    ],
  },
  {
    text: 'UI components',
    items: [
      { text: 'Gradient Borders', link: '/en/ui/gradient-border' },
      { text: 'Cover layout', link: '/en/ui/cover-box' },
      { text: 'Shimmer skeletons', link: '/en/ui/shimmer' },
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

/** One outline for all doc routes under the single top-level「指南」nav item. */
function sidebarForPrefixes(prefixes: string[], groups: typeof sidebarZhGroups) {
  return Object.fromEntries(prefixes.map((prefix) => [prefix, groups]))
}

const docSidebarPrefixesZh = [
  '/guide/',
  '/features/',
  '/ui/',
  '/community/',
]

const docSidebarPrefixesEn = [
  '/en/guide/',
  '/en/features/',
  '/en/ui/',
  '/en/community/',
]

export default defineConfig({
  base: siteBase,
  title: 'Fast Package',
  description: 'Flutter 快速开发工具包文档',
  head: sharedHead,
  srcExclude: ['README.md', '.archive/**'],
  themeConfig: {
    search: sharedSearch,
  },
  locales: {
    root: {
      label: '简体中文',
      lang: 'zh-CN',
      link: '/',
      themeConfig: {
        logo: sharedLogo,
        search: sharedSearch,
        nav: [
          {
            text: '指南',
            link: '/guide/getting-started',
            activeMatch: '^/(guide|features|ui|community)/',
          },
          { text: 'GitHub', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        sidebar: sidebarForPrefixes(docSidebarPrefixesZh, sidebarZhGroups),
        outline: {
          level: [2, 4],
          label: '本页大纲',
        },
        socialLinks: [
          { icon: 'github', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        footer: {
          message: '基于 MIT 许可证发布',
          copyright: 'Copyright © ArturoYi',
        },
      },
    },
    en: {
      label: 'English',
      lang: 'en-US',
      link: '/en/',
      themeConfig: {
        logo: sharedLogo,
        search: sharedSearch,
        nav: [
          {
            text: 'Guide',
            link: '/en/guide/getting-started',
            activeMatch: '^/en/(guide|features|ui|community)/',
          },
          { text: 'GitHub', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        sidebar: sidebarForPrefixes(docSidebarPrefixesEn, sidebarEnGroups),
        outline: {
          level: [2, 4],
          label: 'On this page',
        },
        socialLinks: [
          { icon: 'github', link: 'https://github.com/ArturoYi/fast_package' },
        ],
        footer: {
          message: 'Released under the MIT License',
          copyright: 'Copyright © ArturoYi',
        },
      },
    },
  },
})
