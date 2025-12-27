<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t, te, locale } = useI18n()
const markdownT = useMarkdownT()
watch(
  locale,
  () => usePageHead({ title: t('faq.title') }),
  { immediate: true },
)

const questions = computed(() => {
  const result = []
  for (let i = 1; te(`faq.questions.${i}.question`); i++) {
    result.push({
      question: t(`faq.questions.${i}.question`),
      answer: markdownT(`faq.questions.${i}.answer`),
    })
  }
  return result
})

const visible = computed(() => {
  return import.meta.client && window.screen.width > 768
})
</script>

<template>
  <b-container>
    <article>
      <section>
        <article-title article="faq" />
      </section>
      <b-accordion
        id="questions"
        free
      >
        <b-accordion-item
          v-for="(question, index) in questions"
          :id="`question-${index + 1}`"
          :key="`question-${index + 1}`"
          :title="question.question"
          :visible="visible"
        >
          <div
            class="answer"
            v-html="question.answer"
          />
        </b-accordion-item>
      </b-accordion>
      <b-container class="text-center pt-5">
        <p>
          <em>
            {{ t('faq.questionLeft.text') }}
          </em>
        </p>
        <b-button
          to="/contact/"
          variant="primary"
        >
          <icon name="heroicons:at-symbol" /> {{ t('faq.questionLeft.askButton') }}
        </b-button>
      </b-container>
    </article>
  </b-container>
</template>

<style lang="scss" scoped>
#questions .answer > *:last-child {
  margin-bottom: 0;
}
</style>
