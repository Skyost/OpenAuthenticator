import StylelintPlugin from 'vite-plugin-stylelint'
import eslintPlugin from '@nabla/vite-plugin-eslint'

import { siteMeta } from './site'
import availableLocales from './i18n/availableLocales'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    'nuxt-cname-generator',
    '@nuxtjs/i18n',
    '@nuxt/icon',
    'nuxt-link-checker',
    '@nuxtjs/sitemap',
    '@nuxtjs/robots',
    '@bootstrap-vue-next/nuxt',
  ],
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

  site: {
    url: siteMeta.url,
    name: siteMeta.name,
    trailingSlash: true,
  },

  compatibilityDate: '2024-07-01',

  nitro: {
    prerender: {
      routes: ['/'],
    },
  },

  vite: {
    plugins: [
      StylelintPlugin(),
      eslintPlugin(),
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
          silenceDeprecations: ['mixed-decls', 'color-functions', 'global-builtin', 'import'],
        },
      },
    },
  },

  cname: {
    host: siteMeta.url,
  },

  eslint: {
    config: {
      stylistic: true,
    },
  },

  experimental: {
    defaults: {
      nuxtLink: {
        trailingSlash: 'append',
      },
    },
  },

  i18n: {
    vueI18n: 'i18n.config.ts',
    baseUrl: siteMeta.url,
    locales: availableLocales,
    langDir: './i18n/locales',
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

  icon: {
    provider: 'iconify',
    class: 'vue-icon',
  },

  linkChecker: {
    failOnError: false,
    skipInspections: [
      'link-text',
      'no-uppercase-chars',
    ],
  },
})
