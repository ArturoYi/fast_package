import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import DocCredit from './components/DocCredit.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('DocCredit', DocCredit)
  },
} satisfies Theme
