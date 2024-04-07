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
    <header class="hero">
      <div class="hero-content flex-col lg:flex-row-reverse">
        <div class="max-w-sm relative">
          <blurred-stain />
          <div class="mockup-phone">
            <div class="camera" />
            <div class="display">
              <div class="artboard phone-1">
                <img src="https://placehold.co/320x568" alt="Screenshot">
              </div>
            </div>
          </div>
        </div>
        <div>
          <h1 class="title text-5xl">
            <span class="d-block">{{ t('index.main.title.1') }}</span>
            <br><span v-html="t('index.main.title.2')" />
          </h1>
          <ul class="features py-6">
            <li v-for="(feature, index) in features" :key="`feature-${index}`">
              <icon name="heroicons:check" class="h-6 w-6 me-2" color="oklch(var(--p))" />
              <span v-html="feature" />
            </li>
          </ul>
          <nuxt-link class="btn btn-primary btn-lg btn-wide" to="/#download">
            <icon name="heroicons:arrow-down-tray" class="h-6 w-6" /> {{ t('index.main.downloadButton') }}
          </nuxt-link>
        </div>
      </div>
    </header>
    <div class="bg-neutral text-neutral-content relative flex max-w-[100vw] items-center justify-center overflow-hidden p-10 md:p-20">
      <div class="relative flex max-w-[100rem] flex-col items-center justify-center xl:flex-row xl:gap-20">
        <div class="relative z-[1] w-full py-10">
          <h2 id="download" class="title text-center xl:text-start text-5xl" v-html="t('index.download.title')" />
          <p class="text-center xl:text-start my-10" v-html="t('index.download.description')" />
          <auto-detect-button
            :available-soon-template="t('index.download.storeButtons.availableSoonTemplate')"
            :available-on-template="t('index.download.storeButtons.availableOnTemplate')"
            :loading-text="t('index.download.storeButtons.loading')"
            :more-button="t('index.download.storeButtons.morePlatformsButton')"
          />
        </div>
        <div class="flex flex-col">
          <qrcode-vue
            :value="`${siteMeta.url}/#download`"
            :size="200"
            foreground="oklch(var(--btn-color, var(--b2)) / var(--tw-bg-opacity))"
            background="transparent"
            render-as="svg"
          />
        </div>
      </div>
    </div>
    <div class="relative flex max-w-[100vw] items-center justify-center overflow-hidden p-10 md:p-20">
      <div class="relative flex max-w-[100rem] flex-col items-center justify-center xl:flex-row-reverse xl:gap-20">
        <div>
          <h2 class="text-center title text-5xl leading-none xl:text-start" v-html="t('index.openSource.title')" />
          <div class="text-base-content/70 text-center xl:text-start my-10">
            <p class="mb-6" v-html="t('index.openSource.description.1')" />
            <p v-html="t('index.openSource.description.2')" />
          </div>
          <div class="inline-flex w-full flex-col items-stretch justify-center gap-2 px-4 md:flex-row xl:justify-start xl:px-0">
            <a :href="siteMeta.github" class="btn btn-lg btn-primary btn-wide">
              <icon name="bi:github" class="h-6 w-6" /> {{ t('index.openSource.linkButtons.github') }}
            </a>
            <a href="https://paypal.me/Skyost" class="btn btn-lg btn-wide">
              <icon name="bi:paypal" class="h-6 w-6" /> {{ t('index.openSource.linkButtons.paypal') }}
            </a>
          </div>
        </div>
        <div class="relative shrink-0 pt-10 w-full xl:pt-0 xl:w-1/3">
          <blurred-stain />
          <div class="mockup-window border bg-base-300">
            <div class="flex items-center justify-evenly px-4 py-32 bg-base-100">
              <img class="max-w-20" src="/images/logo.svg" alt="Logo">
              <span class="font-bold text-base-content/70">x</span>
              <img class="max-w-20" src="/images/home/github.svg" alt="Github">
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.title {
  font-weight: lighter;

  strong {
    font-weight: bold;
  }
}
</style>
