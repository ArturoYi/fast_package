import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import DemoLaunch from './components/DemoLaunch.vue'
import DocCredit from './components/DocCredit.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout: () =>
    h(DefaultTheme.Layout, null, {
      'nav-bar-content-after': () => h(DemoLaunch, { variant: 'nav' }),
      'nav-screen-content-after': () => h(DemoLaunch, { variant: 'screen' }),
    }),
  enhanceApp({ app }) {
    app.component('DocCredit', DocCredit)
  },
} satisfies Theme
