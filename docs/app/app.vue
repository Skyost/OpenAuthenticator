<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { availableLocales, locale } = useI18n()

onMounted(() => {
  const i18nCookieValue = useCookie('locale')
  let wantedLanguage = availableLocales[0]
  if (i18nCookieValue.value && availableLocales.includes(i18nCookieValue.value)) {
    wantedLanguage = i18nCookieValue.value
  }
  else {
    const userLanguage = navigator.language || navigator.userLanguage
    const languageCode = userLanguage.indexOf('-') === -1 ? userLanguage : userLanguage.split('-')[0]
    if (availableLocales.includes(languageCode)) {
      wantedLanguage = languageCode
    }
  }
  locale.value = wantedLanguage as string
  watch (locale, newLocale => i18nCookieValue.value = newLocale)
})
</script>

<template>
  <b-app>
    <nuxt-layout>
      <nuxt-page />
    </nuxt-layout>
  </b-app>
</template>
