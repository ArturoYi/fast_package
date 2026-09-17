<script setup lang="ts">
import { computed } from 'vue'
import { useData, withBase } from 'vitepress'

const props = withDefaults(
  defineProps<{
    variant?: 'nav' | 'screen'
  }>(),
  { variant: 'nav' },
)

const { lang } = useData()
const isZh = computed(() => lang.value.startsWith('zh'))
const label = computed(() => (isZh.value ? '在线演示' : 'Live Demo'))
const href = computed(() => withBase('/example/'))
</script>

<template>
  <a
    class="demo-launch"
    :class="`demo-launch--${props.variant}`"
    :href="href"
    target="_blank"
    rel="noopener noreferrer"
  >{{ label }}</a>
</template>
