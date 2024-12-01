<script setup lang="ts">
import availableLocales from '~/i18n/availableLocales'

onMounted(async () => {
  const i18n = useI18n()
  const browserLocale = i18n.getBrowserLocale()
  const locales = i18n.locales
  const locale = locales.value.find(({ code }) => code === browserLocale)
  if (locale && locale != availableLocales[0]) {
    await i18n.setLocale(availableLocales[0].code)
    await i18n.setLocale(locale.code)
  }
})
</script>

<template>
  <nuxt-layout>
    <nuxt-page />
  </nuxt-layout>
</template>
