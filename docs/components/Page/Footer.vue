<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { siteMeta } from '~/site'

const { locale, availableLocales } = useI18n()
// const switchLocalePath = useSwitchLocalePath()
const year = (new Date()).getFullYear()

const getFlagUrl = (locale: string) => {
  if (locale === 'en') {
    locale = 'gb'
  }
  return `https://flagcdn.com/${locale.toLowerCase()}.svg`
}
</script>

<template>
  <footer class="bg-light">
    <b-container class="pt-5 pb-5">
      <b-row>
        <b-col
          sm="12"
          md="4"
          class="mb-4 mb-md-0"
        >
          <h2>{{ $t('footer.app.title') }}</h2>
          <ul>
            <li>
              <nuxt-link to="/">
                {{ $t('footer.app.index') }}
              </nuxt-link>
            </li>
            <li>
              <nuxt-link to="/#download">
                {{ $t('footer.app.download') }}
              </nuxt-link>
            </li>
            <li>
              <nuxt-link to="/translate/">
                {{ $t('footer.app.translation') }}
              </nuxt-link>
            </li>
          </ul>
        </b-col>
        <b-col
          sm="12"
          md="4"
          class="mb-4 mb-md-0"
        >
          <h2>
            {{ $t('footer.legal.title') }}
          </h2>
          <ul>
            <li>
              <nuxt-link :to="`${siteMeta.github}/blob/master/LICENSE`">
                {{ $t('footer.legal.license') }}
              </nuxt-link>
            </li>
            <li>
              <nuxt-link to="/privacy-policy/">
                {{ $t('footer.legal.privacyPolicy') }}
              </nuxt-link>
            </li>
            <li>
              <nuxt-link to="/terms-of-service/">
                {{ $t('footer.legal.termsOfService') }}
              </nuxt-link>
            </li>
            <li>
              <nuxt-link to="/contact/">
                {{ $t('footer.legal.contact') }}
              </nuxt-link>
            </li>
          </ul>
        </b-col>
        <b-col
          sm="12"
          md="4"
        >
          <h2>
            {{ $t('footer.language') }}
          </h2>
          <ul class="icon-list">
            <li
              v-for="availableLocale in availableLocales"
              :key="availableLocale"
            >
              <a
                href="#"
                @click.prevent="locale = availableLocale"
              >
                <img
                  :src="getFlagUrl(availableLocale)"
                  :alt="availableLocale"
                  width="20"
                >
              </a>
            </li>
          </ul>
        </b-col>
      </b-row>
    </b-container>
    <div class="bg-dark-subtle pt-3 pb-3">
      <b-container class="d-flex align-items-center justify-content-between flex-column flex-md-row">
        <div class="d-flex align-items-center">
          <img
            class="avatar me-3"
            src="https://skyost.eu/images/skyost.png"
            alt="Skyost"
          >
          <p class="mb-0">
            Copyright &copy; {{ year }} Skyost<br>Yet another developer
          </p>
        </div>
        <ul class="icon-list">
          <li>
            <a href="https://skyost.eu">
              <icon
                name="bi:globe-europe-africa"
              />
            </a>
          </li>
          <li>
            <a href="https://twitter.com/Skyost">
              <icon
                name="bi:twitter-x"
              />
            </a>
          </li>
          <li>
            <a href="https://github.com/Skyost">
              <icon
                name="bi:github"
              />
            </a>
          </li>
        </ul>
      </b-container>
    </div>
  </footer>
</template>

<style lang="scss" scoped>
h2 {
  font-size: 1.25rem;
  text-transform: uppercase;
}

a {
  color: var(--bs-body-color);
  opacity: 0.8;
  text-decoration: none;

  &:hover {
    opacity: 1;
  }
}

.avatar {
  height: 2em;
  border-radius: 50%;
}

ul {
  margin-bottom: 0;

  &.icon-list {
    padding-left: 0;

    li {
      display: inline-block;
      margin-left: 0.2em;
      margin-right: 0.2em;

      &:first-child {
        margin-left: 0;
      }

      &:last-child {
        margin-right: 0;
      }
    }
  }
}
</style>
