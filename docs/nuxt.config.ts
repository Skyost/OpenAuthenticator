import StylelintPlugin from 'vite-plugin-stylelint'
import eslintPlugin from '@nabla/vite-plugin-eslint'

import { siteMeta } from './site'
import availableLocales from './locales/availableLocales'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },

  app: {
    head: {
      meta: [
        { name: 'theme-color', content: '#ffffff' },
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      ],
    },
  },

  css: [
    '~/assets/app.scss',
  ],

  i18n: {
    baseUrl: siteMeta.url,
    locales: availableLocales,
    langDir: 'locales',
    defaultLocale: 'en',
    strategy: 'no_prefix',
    compilation: {
      escapeHtml: false,
      strictMessage: false,
    },
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'language',
      redirectOn: 'root',
    },
  },

  modules: [
    '@nuxt/eslint',
    'nuxt-cname-generator',
    '@nuxtjs/i18n',
    'nuxt-icon',
    'nuxt-link-checker',
    '@nuxtjs/sitemap',
    'nuxt-simple-robots',
    '@bootstrap-vue-next/nuxt',
  ],

  vite: {
    plugins: [
      StylelintPlugin(),
      eslintPlugin(),
    ],
  },

  site: {
    url: siteMeta.url,
    name: siteMeta.name,
    trailingSlash: true,
  },

  cname: {
    host: siteMeta.url,
  },

  eslint: {
    config: {
      stylistic: true,
    },
  },
})
