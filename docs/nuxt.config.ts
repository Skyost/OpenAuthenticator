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
        { name: 'theme-color', content: '#000000' }
      ]
    }
  },

  css: [
    '~/assets/app.scss'
  ],

  i18n: {
    baseUrl: siteMeta.url,
    locales: availableLocales,
    langDir: 'locales',
    defaultLocale: 'en',
    strategy: 'no_prefix',
    compilation: {
      escapeHtml: false,
      strictMessage: false
    }
  },

  postcss: {
    plugins: {
      tailwindcss: {},
      autoprefixer: {}
    }
  },

  modules: [
    '@nuxt/eslint',
    'nuxt-cname-generator',
    '@nuxtjs/i18n',
    'nuxt-icon',
    'nuxt-link-checker',
    '@nuxtjs/sitemap',
    'nuxt-simple-robots'
  ],

  vite: {
    plugins: [
      StylelintPlugin(),
      eslintPlugin()
    ]
  },

  site: {
    url: siteMeta.url,
    name: siteMeta.name,
    trailingSlash: true
  },

  sitemap: {
    include: availableLocales.map(locale => `/${locale.code}/**`)
  },

  cname: {
    host: siteMeta.url
  }
})
