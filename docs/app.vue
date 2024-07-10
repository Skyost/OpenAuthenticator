<script setup lang="ts">
if (import.meta.client) {
  onMounted(() => {
    const i18n = useI18n()
    const browserLocale = i18n.getBrowserLocale()
    const locales = i18n.locales
    const locale = locales.value.find(({ code }) => code === browserLocale)
    if (locale) {
      i18n.setLocale(locale.code)
    }
  })
}
</script>

<template>
  <nuxt-layout>
    <nuxt-page />
  </nuxt-layout>
</template>
