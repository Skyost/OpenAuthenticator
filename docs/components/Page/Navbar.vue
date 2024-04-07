<script setup lang="ts">
const route = useRoute()

const items = computed(() => [
  {
    title: 'navbar.index',
    to: '/',
    icon: {
      normal: 'heroicons:home',
      active: 'heroicons:home-solid'
    },
    active: route.path === '/'
  },
  {
    title: 'navbar.privacyPolicy',
    to: '/privacy-policy',
    icon: {
      normal: 'heroicons:eye',
      active: 'heroicons:eye-solid'
    },
    active: route.path.startsWith('/privacy-policy')
  },
  {
    title: 'navbar.termsOfService',
    to: '/terms-of-service',
    icon: {
      normal: 'heroicons:document-text',
      active: 'heroicons:document-text-solid'
    },
    active: route.path.startsWith('/terms-of-service')
  },
  {
    title: 'navbar.contact',
    to: '/contact',
    icon: {
      normal: 'heroicons:at-symbol',
      active: 'heroicons:at-symbol-solid'
    },
    active: route.path.startsWith('/contact')
  }
])
</script>

<template>
  <div class="navbar bg-base-100">
    <div class="navbar-start">
      <div class="dropdown">
        <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
          <icon name="heroicons:bars-3-center-left" class="h-5 w-5" />
        </div>
        <ul tabindex="0" class="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52">
          <li v-for="(item, index) in items" :key="`mobile-${index}`">
            <nuxt-link :to="item.to" :class="{'font-bold': item.active}">
              <icon :name="item.active ? item.icon.active : item.icon.normal" />
              {{ $t(item.title) }}
            </nuxt-link>
          </li>
        </ul>
      </div>
      <nuxt-link class="btn btn-link" to="/">
        <img src="/images/logo.svg" alt="Logo" class="h-9 w-9">
      </nuxt-link>
    </div>
    <div class="navbar-center hidden lg:flex">
      <ul class="menu menu-horizontal px-1">
        <li v-for="(item, index) in items" :key="`desktop-${index}`">
          <nuxt-link :to="item.to" :class="{'font-bold': item.active}">
            <icon :name="item.active ? item.icon.active : item.icon.normal" />
            {{ $t(item.title) }}
          </nuxt-link>
        </li>
      </ul>
    </div>
    <div class="navbar-end">
      <nuxt-link to="/#download" class="btn" role="button">
        <icon name="heroicons:arrow-down-tray" class="h-6 w-6" /> {{ $t('navbar.downloadButton') }}
      </nuxt-link>
    </div>
  </div>
</template>
