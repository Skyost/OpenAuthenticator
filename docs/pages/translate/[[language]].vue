<script setup lang="ts">
import LanguagePicker from '~/components/Translation/LanguagePicker.vue'
import ErrorAlert from '~/components/Translation/ErrorAlert.vue'
import Spinner from '~/components/Spinner.vue'

const { t } = useI18n()
const hasChanged = ref<boolean>(false)

usePageHead({ title: t('translate.pageTitle') })
const route = useRoute()
if (route.params.language) {
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
}
</script>

<template>
  <b-container>
    <div
      v-if="!route.params.language"
      class="pt-5 pb-5"
    >
      <div class="pb-3">
        <h1>{{ t('translate.title') }}</h1>
        <p>{{ t('translate.description') }} {{ t('translate.pickLanguage') }}</p>
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
    </div>
    <div
      v-else
      class="pt-5 pb-5"
    >
      <client-only>
        <translation-accordion
          :language="route.params.language.toString()"
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
    </div>
  </b-container>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.language-card {
  text-align: center;
  cursor: pointer;

  .flag {
    height: 50px;
    margin-bottom: 10px;
  }

  &:hover {
    background-color: $light;
  }
}

.back-button {
  font-size: 0.75rem;
  margin-bottom: 1rem;
}
</style>
