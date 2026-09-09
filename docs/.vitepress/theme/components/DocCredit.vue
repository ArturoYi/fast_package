<script setup lang="ts">
import { computed } from 'vue'
import { useData } from 'vitepress'
import { creditLabels, getCredit, type CreditLocale } from '../credits'

const props = defineProps<{
  module: string
}>()

const { lang } = useData()

const locale = computed<CreditLocale>(() =>
  lang.value.startsWith('zh') ? 'zh' : 'en',
)

const credit = computed(() => getCredit(props.module, locale.value))
const label = computed(() => creditLabels[locale.value])
</script>

<template>
  <aside v-if="credit" class="doc-credit" :aria-label="label.source">
    <dl>
      <div>
        <dt>{{ label.source }}</dt>
        <dd>
          <a
            v-if="credit.source.url"
            :href="credit.source.url"
            target="_blank"
            rel="noreferrer"
            >{{ credit.source.name }}</a
          >
          <span v-else>{{ credit.source.name }}</span>
          <span v-if="credit.source.author" class="doc-credit__author">
            ({{ credit.source.author }})
          </span>
        </dd>
      </div>
      <div>
        <dt>{{ label.usage }}</dt>
        <dd>{{ credit.usage }}</dd>
      </div>
      <div>
        <dt>{{ label.improvement }}</dt>
        <dd>{{ credit.improvement }}</dd>
      </div>
    </dl>
  </aside>
</template>
