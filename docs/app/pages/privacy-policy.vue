<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()
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
        <p v-html="t('privacyPolicy.intro')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.userProvidedInfo.title')" />
        <p v-html="t('privacyPolicy.userProvidedInfo.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.automaticallyCollectedInfo.title')" />
        <p v-html="t('privacyPolicy.automaticallyCollectedInfo.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.locationInfo.title')" />
        <p v-html="t('privacyPolicy.locationInfo.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.thirdPartyAccess.title')" />
        <p v-html="t('privacyPolicy.thirdPartyAccess.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.thirdPartyProviders.title')" />
        <p v-html="t('privacyPolicy.thirdPartyProviders.content')" />
        <ul>
          <li v-html="t('privacyPolicy.thirdPartyProviders.list.googlePlayServices')" />
          <li v-html="t('privacyPolicy.thirdPartyProviders.list.firebase')" />
          <li v-html="t('privacyPolicy.thirdPartyProviders.list.revenueCat')" />
        </ul>
        <p v-html="t('privacyPolicy.thirdPartyProviders.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.disclosure.title')" />
        <p v-html="t('privacyPolicy.disclosure.content')" />
        <ul>
          <li v-html="t('privacyPolicy.disclosure.list.1')" />
          <li v-html="t('privacyPolicy.disclosure.list.2')" />
          <li v-html="t('privacyPolicy.disclosure.list.3')" />
        </ul>
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.optOut.title')" />
        <p v-html="t('privacyPolicy.optOut.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.dataRetention.title')" />
        <p v-html="t('privacyPolicy.dataRetention.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.children.title')" />
        <p v-html="t('privacyPolicy.children.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.security.title')" />
        <p v-html="t('privacyPolicy.security.content')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.changes.title')" />
        <p v-html="t('privacyPolicy.changes.content')" />
        <p v-html="t('privacyPolicy.changes.effectiveDate')" />
      </section>
      <section>
        <h2 v-html="t('privacyPolicy.contact.title')" />
        <p v-html="t('privacyPolicy.contact.content')" />
      </section>
      <div class="text-end">
        <small v-html="t('privacyPolicy.credit')" />
      </div>
    </article>
  </b-container>
</template>
