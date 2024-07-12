<template>
  <b-container>
    <article>
      <page-head :title="$t('termsOfService.title')" />
      <section>
        <article-title article="termsOfService" />
        <p v-html="$t('termsOfService.intro')" />
        <p v-html="$t('termsOfService.agreement')" />
        <p v-html="$t('termsOfService.modification')" />
        <p v-html="$t('termsOfService.dataProcessing')" />
        <p v-html="$t('termsOfService.thirdPartyTerms')" />
        <ul>
          <li v-html="$t('termsOfService.thirdPartyTermsList.googlePlayServices')" />
          <li v-html="$t('termsOfService.thirdPartyTermsList.firebase')" />
          <li v-html="$t('termsOfService.thirdPartyTermsList.revenueCat')" />
        </ul>
        <p v-html="$t('termsOfService.responsibility')" />
        <p v-html="$t('termsOfService.charges')" />
        <p v-html="$t('termsOfService.battery')" />
        <p v-html="$t('termsOfService.termination')" />
      </section>
      <section>
        <h2 v-html="$t('termsOfService.legalRiskResponsibility.title')" />
        <h3 v-html="$t('termsOfService.legalRiskResponsibility.noWarranty.title')" />
        <p v-html="$t('termsOfService.legalRiskResponsibility.noWarranty.content')" />
        <h3 v-html="$t('termsOfService.legalRiskResponsibility.synchronizationSecurity.title')" />
        <p v-html="$t('termsOfService.legalRiskResponsibility.synchronizationSecurity.content')" />
        <h3 v-html="$t('termsOfService.legalRiskResponsibility.releaseIndemnity.title')" />
        <p v-html="$t('termsOfService.legalRiskResponsibility.releaseIndemnity.content')" />
        <h3 v-html="$t('termsOfService.legalRiskResponsibility.limitationOfLiability.title')" />
        <p v-html="$t('termsOfService.legalRiskResponsibility.limitationOfLiability.content')" />
      </section>
      <section>
        <h2 v-html="$t('termsOfService.changes.title')" />
        <p v-html="$t('termsOfService.changes.content')" />
        <p v-html="$t('termsOfService.changes.effectiveDate')" />
      </section>
      <section>
        <h2 v-html="$t('termsOfService.contact.title')" />
        <p v-html="$t('termsOfService.contact.content')" />
      </section>
      <div class="text-end">
        <small v-html="$t('termsOfService.credit')" />
      </div>
    </article>
  </b-container>
</template>
