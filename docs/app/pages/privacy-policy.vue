<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()
const markdownT = useMarkdownT()
watch(
  locale,
  () => usePageHead({ title: t('privacyPolicy.title') }),
  { immediate: true },
)
</script>

<template>
  <b-container>
    <article>
      <section>
        <article-title article="privacyPolicy" />
        <p v-html="markdownT('privacyPolicy.intro')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.userProvidedInfo.title')" />
        <p v-html="markdownT('privacyPolicy.userProvidedInfo.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.automaticallyCollectedInfo.title')" />
        <p v-html="markdownT('privacyPolicy.automaticallyCollectedInfo.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.locationInfo.title')" />
        <p v-html="markdownT('privacyPolicy.locationInfo.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.thirdPartyAccess.title')" />
        <p v-html="markdownT('privacyPolicy.thirdPartyAccess.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.thirdPartyProviders.title')" />
        <p v-html="markdownT('privacyPolicy.thirdPartyProviders.content')" />
        <ul>
          <li v-html="markdownT('privacyPolicy.thirdPartyProviders.list.googlePlayServices')" />
          <li v-html="markdownT('privacyPolicy.thirdPartyProviders.list.firebase')" />
          <li v-html="markdownT('privacyPolicy.thirdPartyProviders.list.revenueCat')" />
        </ul>
        <p v-html="markdownT('privacyPolicy.thirdPartyProviders.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.disclosure.title')" />
        <p v-html="markdownT('privacyPolicy.disclosure.content')" />
        <ul>
          <li v-html="markdownT('privacyPolicy.disclosure.list.1')" />
          <li v-html="markdownT('privacyPolicy.disclosure.list.2')" />
          <li v-html="markdownT('privacyPolicy.disclosure.list.3')" />
        </ul>
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.optOut.title')" />
        <p v-html="markdownT('privacyPolicy.optOut.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.dataRetention.title')" />
        <p v-html="markdownT('privacyPolicy.dataRetention.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.children.title')" />
        <p v-html="markdownT('privacyPolicy.children.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.security.title')" />
        <p v-html="markdownT('privacyPolicy.security.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.changes.title')" />
        <p v-html="markdownT('privacyPolicy.changes.content')" />
        <p v-html="markdownT('privacyPolicy.changes.effectiveDate')" />
      </section>
      <section>
        <h2 v-html="markdownT('privacyPolicy.contact.title')" />
        <p v-html="markdownT('privacyPolicy.contact.content')" />
      </section>
      <div class="text-end">
        <small v-html="markdownT('privacyPolicy.credit')" />
      </div>
    </article>
  </b-container>
</template>

<style lang="scss" scoped>
@import 'assets/article';
</style>
