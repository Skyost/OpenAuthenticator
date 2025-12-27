import { fileURLToPath } from 'url'
import * as path from 'path'
import StylelintPlugin from 'vite-plugin-stylelint'
import eslintPlugin from '@nabla/vite-plugin-eslint'
import VueI18nVitePlugin from '@intlify/unplugin-vue-i18n/vite'

import { siteMeta } from './app/site'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: [
    '@nuxt/eslint',
    'nuxt-cname-generator',
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

  build: {
    transpile: ['vue-i18n'],
  },

  experimental: {
    defaults: {
      nuxtLink: {
        trailingSlash: 'append',
      },
    },
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
      VueI18nVitePlugin({
        strictMessage: false,
        include: [
          path.resolve(path.dirname(fileURLToPath(import.meta.url)), './locales/*.json'),
        ],
      }),
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
          silenceDeprecations: ['if-function', 'color-functions', 'global-builtin', 'import'],
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
