<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t, locale } = useI18n()
const markdownT = useMarkdownT()
watch(
  locale,
  () => usePageHead({ title: t('termsOfService.title') }),
  { immediate: true },
)
</script>

<template>
  <b-container>
    <article>
      <section>
        <article-title article="termsOfService" />
        <p v-html="markdownT('termsOfService.intro')" />
        <p v-html="markdownT('termsOfService.agreement')" />
        <p v-html="markdownT('termsOfService.modification')" />
        <p v-html="markdownT('termsOfService.dataProcessing')" />
        <p v-html="markdownT('termsOfService.thirdPartyTerms')" />
        <ul>
          <li v-html="markdownT('termsOfService.thirdPartyTermsList.googlePlayServices')" />
          <li v-html="markdownT('termsOfService.thirdPartyTermsList.firebase')" />
          <li v-html="markdownT('termsOfService.thirdPartyTermsList.revenueCat')" />
        </ul>
        <p v-html="markdownT('termsOfService.responsibility')" />
        <p v-html="markdownT('termsOfService.charges')" />
        <p v-html="markdownT('termsOfService.battery')" />
        <p v-html="markdownT('termsOfService.termination')" />
      </section>
      <section>
        <h2 v-html="markdownT('termsOfService.legalRiskResponsibility.title')" />
        <h3 v-html="markdownT('termsOfService.legalRiskResponsibility.noWarranty.title')" />
        <p v-html="markdownT('termsOfService.legalRiskResponsibility.noWarranty.content')" />
        <h3 v-html="markdownT('termsOfService.legalRiskResponsibility.synchronizationSecurity.title')" />
        <p v-html="markdownT('termsOfService.legalRiskResponsibility.synchronizationSecurity.content')" />
        <h3 v-html="markdownT('termsOfService.legalRiskResponsibility.releaseIndemnity.title')" />
        <p v-html="markdownT('termsOfService.legalRiskResponsibility.releaseIndemnity.content')" />
        <h3 v-html="markdownT('termsOfService.legalRiskResponsibility.limitationOfLiability.title')" />
        <p v-html="markdownT('termsOfService.legalRiskResponsibility.limitationOfLiability.content')" />
      </section>
      <section>
        <h2 v-html="markdownT('termsOfService.changes.title')" />
        <p v-html="markdownT('termsOfService.changes.content')" />
        <p v-html="markdownT('termsOfService.changes.effectiveDate')" />
      </section>
      <section>
        <h2 v-html="markdownT('termsOfService.contact.title')" />
        <p v-html="markdownT('termsOfService.contact.content')" />
      </section>
      <div class="text-end">
        <small v-html="markdownT('termsOfService.credit')" />
      </div>
    </article>
  </b-container>
</template>

<style lang="scss" scoped>
@import 'assets/article';
</style>
