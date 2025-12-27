<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import type { LanguageWithData } from '~~/modules/get-info-from-parent'
import LanguageCard from '~/components/Translation/LanguageCard.vue'

const { data: languages, status, error } = await useFetch<Record<string, LanguageWithData>>('/_app/languages.json')

const { t, locale } = useI18n()
const markdownT = useMarkdownT()
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
        <span v-html="markdownT('translate.pickLanguage')" />
      </p>
    </div>
    <div v-if="status === 'pending'">
      <spinner />
    </div>
    <div v-else-if="languages">
      <b-row>
        <b-col
          v-for="language in languages"
          :key="language.code"
          sm="12"
          md="4"
          class="mb-3"
        >
          <language-card :language="language" />
        </b-col>
      </b-row>
      <span class="credits">
        Flags provided by <a href="https://flagpedia.net">Flagpedia</a>.
      </span>
    </div>
    <div v-else>
      <error-display :error="error" />
    </div>
  </b-container>
</template>
