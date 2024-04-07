<script setup lang="ts">
import type { LocaleObject } from '@nuxtjs/i18n'
import { siteMeta } from '~/site'

const { locales, setLocale } = useI18n()
// const switchLocalePath = useSwitchLocalePath()
const year = (new Date()).getFullYear()

const getFlagUrl = (locale: LocaleObject) => {
  let code = locale.code
  if (code === 'en') {
    code = 'gb'
  }
  return `https://flagcdn.com/${code.toLowerCase()}.svg`
}
</script>

<template>
  <div>
    <footer class="footer p-10 bg-base-200 text-base-content">
      <nav>
        <h2 class="footer-title">{{ $t('footer.app.title') }}</h2>
        <nuxt-link to="/" class="link link-hover">{{ $t('footer.app.index') }}</nuxt-link>
        <nuxt-link to="/#download" class="link link-hover">{{ $t('footer.app.download') }}</nuxt-link>
      </nav>
      <nav>
        <h2 class="footer-title">{{ $t('footer.legal.title') }}</h2>
        <nuxt-link :to="`${siteMeta.github}/blob/master/LICENSE`" class="link link-hover">{{ $t('footer.legal.license') }}</nuxt-link>
        <nuxt-link to="/privacy-policy" class="link link-hover">{{ $t('footer.legal.privacyPolicy') }}</nuxt-link>
        <nuxt-link to="/terms-of-service" class="link link-hover">{{ $t('footer.legal.termsOfService') }}</nuxt-link>
        <nuxt-link to="/contact" class="link link-hover">{{ $t('footer.legal.contact') }}</nuxt-link>
      </nav>
      <nav>
        <h2 class="footer-title">{{ $t('footer.language') }}</h2>
        <div class="flex items-center gap-1">
          <a
            v-for="locale in locales"
            :key="locale.code"
            href="#"
            @click.prevent="setLocale(locale.code)"
          >
            <img :src="getFlagUrl(locale)" :alt="locale.code" width="20">
          </a>
        </div>
      </nav>
    </footer>
    <footer class="footer px-10 py-4 border-t bg-base-200 text-base-content border-base-300">
      <aside class="items-center grid-flow-col">
        <div class="avatar">
          <div class="w-10 rounded-full">
            <img
              src="https://skyost.eu/images/skyost.png"
              class="fill-current"
              alt="Skyost"
            >
          </div>
        </div>
        <p>Copyright &copy; {{ year }} Skyost<br>Yet another developer</p>
      </aside>
      <nav class="md:place-self-center md:justify-self-end">
        <div class="grid grid-flow-col gap-4">
          <a href="https://skyost.eu">
            <icon name="bi:globe-europe-africa" class="h-6 w-6" />
          </a>
          <a href="https://twitter.com/Skyost">
            <icon name="bi:twitter-x" class="h-6 w-6" />
          </a>
          <a href="https://github.com/Skyost">
            <icon name="bi:github" class="h-6 w-6" />
          </a>
        </div>
      </nav>
    </footer>
  </div>
</template>
