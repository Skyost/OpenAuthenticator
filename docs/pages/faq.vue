<template>
  <b-container>
    <article>
      <page-head :title="$t('faq.title')" />
      <section>
        <article-title article="faq" />
      </section>
      <b-accordion id="questions" free>
        <b-accordion-item
          id="question-1"
          :title="$t('faq.questions.1.question')"
          visible
        >
          <p v-html="$t('faq.questions.1.answer.1')" />
          <p
            class="mb-0"
            v-html="$t('faq.questions.1.answer.2')"
          />
        </b-accordion-item>
        <b-accordion-item
          id="question-2"
          :title="$t('faq.questions.2.question')"
          visible
        >
          <p
            class="mb-0"
            v-html="$t('faq.questions.2.answer')"
          />
        </b-accordion-item>
        <b-accordion-item
          id="question-3"
          :title="$t('faq.questions.3.question')"
          visible
        >
          <p v-html="$t('faq.questions.3.answer.1')" />
          <ol>
            <li v-html="$t('faq.questions.3.answer.list.1')" />
            <li v-html="$t('faq.questions.3.answer.list.2')" />
            <li v-html="$t('faq.questions.3.answer.list.3')" />
          </ol>
          <p v-html="$t('faq.questions.3.answer.2')" />
          <p
            class="mb-0"
            v-html="$t('faq.questions.3.answer.3')"
          />
        </b-accordion-item>
      </b-accordion>
      <b-container class="text-center pt-5">
        <p>
          <em>
            {{ $t('faq.questionLeft.text') }}
          </em>
        </p>
        <b-button
          to="/contact/"
          variant="primary"
        >
          <icon name="heroicons:at-symbol" /> {{ $t('faq.questionLeft.askButton') }}
        </b-button>
      </b-container>
    </article>
  </b-container>
</template>
