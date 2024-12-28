<script setup lang="ts">
import LanguageCard from '~/components/Translation/LanguageCard.vue'
import type { LanguageWithData } from '~/modules/get-info-from-parent'

const props = withDefaults(defineProps<{
  ignore?: string[]
}>(), {
  ignore: () => ['en'],
})

const { data, status, error } = await useFetch<Record<string, LanguageWithData>>('/_app/languages.json')

const languages = computed<LanguageWithData[]>(() => {
  if (!data.value) {
    return []
  }
  const result: LanguageWithData[] = []
  for (const language of Object.values(data.value)) {
    if (!props.ignore.includes(language.code)) {
      result.push(language)
    }
  }
  return result
})
</script>

<template>
  <div v-if="status === 'pending'">
    <slot name="pending" />
  </div>
  <b-row v-else-if="data">
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
  <div v-else>
    <slot
      name="error"
      :error="error"
    />
  </div>
</template>
