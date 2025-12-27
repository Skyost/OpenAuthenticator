<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import LanguagePicker from '~/components/Translation/LanguagePicker.vue'
import ErrorAlert from '~/components/Translation/ErrorAlert.vue'

const { t, locale } = useI18n()
watch(
  locale,
  () => usePageHead({ title: t('translate.pageTitle') }),
  { immediate: true },
)
</script>

<template>
  <b-container class="pt-5 pb-5">
    <div class="pb-3">
      <h1>{{ t('translate.title') }}</h1>
      <p>
        {{ t('translate.description') }}
        <span v-html="t('translate.pickLanguage')" />
      </p>
    </div>
    <client-only>
      <language-picker>
        <template #loading>
          <spinner />
        </template>
        <template #error="slotProps">
          <error-alert :error="slotProps.error" />
        </template>
      </language-picker>
      <template #fallback>
        <spinner />
      </template>
    </client-only>
  </b-container>
</template>
