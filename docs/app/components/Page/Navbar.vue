<script setup lang="ts">
const route = useRoute()

const items = computed(() => [
  {
    title: 'navbar.index',
    to: '/',
    icon: {
      normal: 'heroicons:home',
      active: 'heroicons:home-solid',
    },
    active: route.path === '/',
  },
  {
    title: 'navbar.faq',
    to: '/faq/',
    icon: {
      normal: 'heroicons:question-mark-circle',
      active: 'heroicons:question-mark-circle-solid',
    },
    active: route.path.startsWith('/faq'),
  },
  {
    title: 'navbar.privacyPolicy',
    to: '/privacy-policy/',
    icon: {
      normal: 'heroicons:eye',
      active: 'heroicons:eye-solid',
    },
    active: route.path.startsWith('/privacy-policy'),
  },
  {
    title: 'navbar.termsOfService',
    to: '/terms-of-service/',
    icon: {
      normal: 'heroicons:document-text',
      active: 'heroicons:document-text-solid',
    },
    active: route.path.startsWith('/terms-of-service'),
  },
  {
    title: 'navbar.contact',
    to: '/contact/',
    icon: {
      normal: 'heroicons:at-symbol',
      active: 'heroicons:at-symbol-solid',
    },
    active: route.path.startsWith('/contact'),
  },
])
</script>

<template>
  <b-navbar
    v-b-color-mode="'light'"
    toggleable="lg"
    :variant="null"
  >
    <b-navbar-toggle target="nav-collapse" />
    <b-collapse
      id="nav-collapse"
      is-nav
    >
      <b-navbar-nav class="ms-auto me-auto">
        <b-nav-item
          v-for="(item, index) in items"
          :key="`navbar-item-${index}`"
          :to="item.to"
          :class="{ 'fw-bold': item.active }"
        >
          <icon :name="item.active ? item.icon.active : item.icon.normal" />
          {{ $t(item.title) }}
        </b-nav-item>
      </b-navbar-nav>
      <b-navbar-nav class="download">
        <b-button
          to="/#download"
          variant="primary"
        >
          <icon name="heroicons:arrow-down-tray" /> {{ $t('navbar.downloadButton') }}
        </b-button>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';

.download {
  position: absolute;
  right: var(--bs-navbar-padding-y);

  @include media-breakpoint-down(lg) {
    position: relative;
  }
}
</style>
