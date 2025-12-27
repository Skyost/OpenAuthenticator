<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ErrorAlert from '~/components/Translation/ErrorAlert.vue'

const { t, locale } = useI18n()
watch(
  locale,
  () => usePageHead({ title: t('translate.pageTitle') }),
  { immediate: true },
)

const hasChanged = ref<boolean>(false)
const router = useRouter()
const removeGuard = router.beforeEach((to, from, next) => {
  if (!hasChanged.value) {
    next()
    return
  }
  const confirmation = confirm(t('translate.unsavedChanges'))
  if (confirmation) {
    next()
  }
})
onUnmounted(removeGuard)
</script>

<template>
  <b-container class="pt-5 pb-5">
    <client-only>
      <translation-accordion
        :language="$route.params.language!.toString()"
        @update="hasChanged = true"
      >
        <template #title="slotProps">
          <div class="pb-3">
            <h1>{{ slotProps.language.name }}</h1>
            <div v-html="t('translate.languageDescription')" />
            <div class="text-end">
              <nuxt-link
                class="back-button"
                to="/translate/"
              >
                {{ t('translate.notYourLanguage') }}
              </nuxt-link>
            </div>
          </div>
        </template>
        <template #loading>
          <spinner />
        </template>
        <template #error="slotProps">
          <error-alert :error="slotProps.error" />
        </template>
      </translation-accordion>
      <template #fallback>
        <spinner />
      </template>
    </client-only>
  </b-container>
</template>

<style lang="scss" scoped>
.back-button {
  font-size: 0.75rem;
  margin-bottom: 1rem;
}
</style>
