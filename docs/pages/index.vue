<script setup lang="ts">
import QrcodeVue from 'qrcode.vue'
import AutoDetectButton from '~/components/Store/AutoDetectButton.vue'
import { siteMeta } from '~/site'

const { t, te } = useI18n()

const features = computed(() => {
  const result = []
  for (let i = 1; te(`index.main.features.${i}`); i++) {
    result.push(t(`index.main.features.${i}`))
  }
  return result
})
</script>

<template>
  <div>
    <page-head />
    <header class="pt-5 pb-5">
      <b-container>
        <b-row>
          <b-col
            sm="12"
            md="7"
            lg="8"
            class="d-flex align-items-center"
          >
            <div class="text-center text-md-start mb-5 mb-md-0">
              <h1>
                <span class="d-block">{{ t('index.main.title.1') }}</span>
                <span v-html="t('index.main.title.2')" />
              </h1>
              <ul class="list-unstyled text-start mt-3 mb-5">
                <li
                  v-for="(feature, index) in features"
                  :key="`feature-${index}`"
                >
                  <icon
                    name="heroicons:check"
                    class="me-2 text-primary"
                  />
                  <span v-html="feature" />
                </li>
              </ul>
              <b-button
                variant="primary"
                to="/#download"
                size="lg"
              >
                <icon
                  name="heroicons:arrow-down-tray"
                  class="h-6 w-6"
                /> {{ t('index.main.downloadButton') }}
              </b-button>
            </div>
          </b-col>
          <b-col
            sm="12"
            md="5"
            lg="4"
            class="position-relative"
          >
            <blurred-stain :center="true" />
            <mobile-phone class="phone">
              <img
                class="mw-100"
                src="/images/screenshots/home.png"
                alt="Screenshot"
              >
            </mobile-phone>
          </b-col>
        </b-row>
      </b-container>
    </header>
    <div class="bg-dark text-light pt-5 pb-5">
      <b-container>
        <b-row>
          <b-col
            sm="12"
            lg="9"
          >
            <div class="text-center text-lg-start">
              <h2
                id="download"
                v-html="t('index.download.title')"
              />
              <p
                class="mt-3 mb-3"
                v-html="t('index.download.description')"
              />
            </div>
            <auto-detect-button
              :available-soon-template="t('index.download.storeButtons.availableSoonTemplate')"
              :available-on-template="t('index.download.storeButtons.availableOnTemplate')"
              :loading-text="t('index.download.storeButtons.loading')"
              :more-button="t('index.download.storeButtons.morePlatformsButton')"
            />
          </b-col>
          <b-col class="align-items-center justify-content-center d-none d-lg-flex">
            <qrcode-vue
              :value="`${siteMeta.url}/#download`"
              :size="200"
              foreground="var(--bs-light)"
              background="transparent"
              render-as="svg"
            />
          </b-col>
        </b-row>
      </b-container>
    </div>
    <b-container class="pt-5 pb-5">
      <b-row>
        <b-col
          class="d-none d-md-block position-relative"
          md="6"
          lg="5"
        >
          <blurred-stain />
          <window>
            <div class="os-window">
              <img
                class="os-logo"
                src="/images/logo.svg"
                alt="Logo"
              >
              <span class="font-bold text-base-content/70">x</span>
              <img
                class="os-logo"
                src="/images/home/github.svg"
                alt="Github"
              >
            </div>
          </window>
        </b-col>
        <b-col class="d-flex align-items-center">
          <div class="text-center text-md-start">
            <h2 v-html="t('index.openSource.title')" />
            <div class="mt-3 mb-3">
              <p v-html="t('index.openSource.description.1')" />
              <p v-html="t('index.openSource.description.2')" />
            </div>
            <b-row>
              <b-col
                sm="12"
                lg="6"
                class="mb-2 mb-lg-0"
              >
                <b-button
                  class="w-100"
                  variant="primary"
                  :href="siteMeta.github"
                >
                  <icon name="bi:github" /> {{ t('index.openSource.linkButtons.github') }}
                </b-button>
              </b-col>
              <b-col
                sm="12"
                lg="6"
              >
                <b-button
                  class="w-100"
                  variant="light"
                  href="https://paypal.me/Skyost"
                >
                  <icon name="bi:paypal" /> {{ t('index.openSource.linkButtons.paypal') }}
                </b-button>
              </b-col>
            </b-row>
          </div>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<style lang="scss" scoped>
.os-window {
  display: flex;
  align-items: center;
  justify-content: space-evenly;
  min-height: 250px;

  .os-logo {
    max-width: 20%;
  }
}
</style>
