export type CreditLocale = 'zh' | 'en'

export interface CreditSource {
  name: string
  url: string
  author: string
}

export interface LocalizedCredit {
  source: CreditSource
  usage: string
  improvement: string
}

const labels = {
  zh: {
    source: '借鉴来源',
    usage: '使用场景',
    improvement: '做出的改善',
  },
  en: {
    source: 'Source',
    usage: 'Typical use',
    improvement: 'What we changed',
  },
} as const

export const creditLabels = labels

export const credits: Record<string, Record<CreditLocale, LocalizedCredit>> = {
  debounce: {
    zh: {
      source: {
        name: 'easy_debounce',
        url: 'https://github.com/magnuswikhog/easy_debounce',
        author: 'Magnus Wikhog',
      },
      usage: '搜索联想、按钮防连点、滚动分页。',
      improvement: '拆成三个类，改用 named 参数。',
    },
    en: {
      source: {
        name: 'easy_debounce',
        url: 'https://github.com/magnuswikhog/easy_debounce',
        author: 'Magnus Wikhog',
      },
      usage: 'Search suggestions, tap-guards, scroll paging.',
      improvement: 'Split into three classes with named parameters.',
    },
  },
  'async-queue': {
    zh: {
      source: {
        name: 'async_queue',
        url: 'https://github.com/samderlust/async_queue',
        author: 'samderlust',
      },
      usage: '上传队列、串行 API、离线同步。',
      improvement: '无参 AsyncJob，并补齐 JobInfo / addJobThrow。',
    },
    en: {
      source: {
        name: 'async_queue',
        url: 'https://github.com/samderlust/async_queue',
        author: 'samderlust',
      },
      usage: 'Upload queues, serial APIs, offline sync.',
      improvement: 'Parameterless AsyncJob, plus JobInfo / addJobThrow.',
    },
  },
  'gradient-border': {
    zh: {
      source: {
        name: 'gradient_borders',
        url: 'https://pub.dev/packages/gradient_borders',
        author: 'The Code Brothers',
      },
      usage: '卡片、按钮等需要渐变描边的容器。',
      improvement: '只保留 Box 描边，单文件零依赖。',
    },
    en: {
      source: {
        name: 'gradient_borders',
        url: 'https://pub.dev/packages/gradient_borders',
        author: 'The Code Brothers',
      },
      usage: 'Cards and buttons that need a gradient stroke.',
      improvement: 'Box stroke only; one file, no extra deps.',
    },
  },
  shimmer: {
    zh: {
      source: {
        name: 'shimmer_animation_kit',
        url: 'https://github.com/Sachu-Alex/shimmer_animation_kit',
        author: 'Sachu-Alex',
      },
      usage: '列表骨架，以及扫光文字、滑动解锁提示。',
      improvement: '不做自动推断，skeleton 必填；装饰扫光另走 Highlight。',
    },
    en: {
      source: {
        name: 'shimmer_animation_kit',
        url: 'https://github.com/Sachu-Alex/shimmer_animation_kit',
        author: 'Sachu-Alex',
      },
      usage: 'List skeletons, plus highlight text and slide-to-unlock hints.',
      improvement: 'No auto-detect; skeleton is required. Decorative sweep uses Highlight.',
    },
  },
  toast: {
    zh: {
      source: {
        name: 'Overlay Toast 常见方案',
        url: '',
        author: '',
      },
      usage: '全局轻提示，无需 BuildContext。',
      improvement: '只留 showToast，自定义走 builder，单 Overlay。',
    },
    en: {
      source: {
        name: 'Common Overlay Toast approach',
        url: '',
        author: '',
      },
      usage: 'Global lightweight toasts without BuildContext.',
      improvement: 'Only showToast; custom content uses builder; one overlay.',
    },
  },
  loading: {
    zh: {
      source: {
        name: 'Overlay Loading 常见方案',
        url: '',
        author: '',
      },
      usage: '全局加载中，无需 BuildContext。',
      improvement: '只居中、无队列，遮罩拦截点击。',
    },
    en: {
      source: {
        name: 'Common Overlay Loading approach',
        url: '',
        author: '',
      },
      usage: 'Global loading overlay without BuildContext.',
      improvement: 'Center only, no queue; barrier blocks taps.',
    },
  },
  refresh: {
    zh: {
      source: {
        name: 'EasyRefresh',
        url: 'https://github.com/xuelongqy/flutter_easy_refresh',
        author: 'xuelongqy',
      },
      usage: '列表下拉刷新、上拉加载。',
      improvement: '仅依赖 Flutter SDK，默认 Classic。可选 Material 指示器；日常分页用 FastPagingList 传入 fetchPage 即可，不必继承 FastPaging。',
    },
    en: {
      source: {
        name: 'EasyRefresh',
        url: 'https://github.com/xuelongqy/flutter_easy_refresh',
        author: 'xuelongqy',
      },
      usage: 'Pull-to-refresh and load-more on lists.',
      improvement: 'Flutter SDK only; Classic remains the default. Optional Material indicators; FastPagingList takes fetchPage, so everyday paging needs no FastPaging subclass.',
    },
  },
  'animated-list': {
    zh: {
      source: {
        name: 'flutter_staggered_animations',
        url: 'https://github.com/mobiten/flutter_staggered_animations',
        author: 'mobiten / Dailyn',
      },
      usage: '列表 / 网格首屏错开入场，以及增删和拖拽排序。',
      improvement:
        '拆成 Animated / Reorderable 两个入口再组合；共享 ticker + 首帧 Limiter；大 diff 整表对齐。不移植 per-item AnimationController。',
    },
    en: {
      source: {
        name: 'flutter_staggered_animations',
        url: 'https://github.com/mobiten/flutter_staggered_animations',
        author: 'mobiten / Dailyn',
      },
      usage: 'First-frame staggered entrance, plus insert/remove and drag reorder.',
      improvement:
        'Split into Animated and Reorderable entry points, then a composite; one shared ticker and a first-frame limiter; large diffs snap. No per-item AnimationController.',
    },
  },
  slidable: {
    zh: {
      source: {
        name: 'flutter_slidable',
        url: 'https://github.com/letsar/flutter_slidable',
        author: 'Romain Rastel',
      },
      usage: '列表项左右滑出操作、满滑删除。',
      improvement: '满滑与删除拆成两段阈值；ThemeExtension；与竖直 FastRefresh 共存时刷新中锁模。不移植旧通知 API。',
    },
    en: {
      source: {
        name: 'flutter_slidable',
        url: 'https://github.com/letsar/flutter_slidable',
        author: 'Romain Rastel',
      },
      usage: 'Swipe rows to reveal actions or dismiss.',
      improvement: 'Full swipe and dismiss are separate thresholds; ThemeExtension; locks while a vertical FastRefresh is active. No legacy notification API.',
    },
  },
}

export function getCredit(
  module: string,
  locale: CreditLocale,
): LocalizedCredit | undefined {
  return credits[module]?.[locale]
}
