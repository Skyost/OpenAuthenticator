<script setup lang="ts">
import type { BaseColorVariant } from 'bootstrap-vue-next'
import type { LanguageWithData } from '~/modules/get-info-from-parent'

const props = defineProps<{
  language: LanguageWithData
}>()

const progress = ref<number>(0)

onMounted(() => {
  setTimeout(() => progress.value = props.language.progress, 500)
})

const variant = computed<keyof BaseColorVariant>(() => {
  if (props.language.progress >= 0.75) {
    return 'success'
  }
  if (props.language.progress >= 0.5) {
    return 'warning'
  }
  return 'danger'
})
const animate = ref<boolean>(false)
</script>

<template>
  <nuxt-link
    class="d-block"
    :to="`/translate/${language.code}/`"
    @mouseover="animate = true"
    @mouseleave="animate = false"
  >
    <b-card class="language-card">
      <img
        class="flag"
        :src="`https://flagcdn.com/${language.code}.svg`"
        :alt="language.name"
      >
      <b-card-text>
        {{ language.name }}
      </b-card-text>
      <div class="d-flex align-items-center">
        <b-progress
          class="progress"
          :max="1"
          striped
          :animated="animate"
          :value="progress"
          :variant="variant"
        />
        <span class="label ps-2">
          {{ Math.round(language.progress * 100) }}%
        </span>
      </div>
    </b-card>
  </nuxt-link>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

a {
  text-decoration: none;

  .language-card {
    text-align: center;

    .flag {
      height: 50px;
      margin-bottom: 10px;
    }

    .progress {
      width: 100%;

      :deep(.progress-bar) {
        transition-duration: 800ms;
        transition-property: width;
        transition-timing-function: ease-in-out;
      }
    }
  }

  &:hover .language-card {
    background-color: $light;
  }
}
</style>
