<script setup lang="ts">
import { siteMeta } from '~/site'

const url = new URL(siteMeta.github)
const { data } = useFetch(`https://api.github.com/repos${url.pathname}/releases/latest`)
</script>

<template>
  <span v-if="data && data.name">
    <slot name="prefix" /> {{ data.name }}<slot name="suffix" />
  </span>
</template>
