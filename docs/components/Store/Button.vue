<script setup lang="ts">
import { storesLink, type StoreInfo, type OS } from '~/site'

const props = defineProps<{
  os: OS,
  availableSoonTemplate?: string,
  availableOnTemplate?: string
}>()

interface ExtendedStoreInfo extends StoreInfo {
  image: string,
  target: string
}

const store = computed<ExtendedStoreInfo>(() => {
  switch (props.os) {
    case 'android':
      return {
        ...storesLink.android,
        image: '/images/stores/google-play.svg',
        target: 'Android'
      }
    case 'darwin':
      return {
        ...storesLink.darwin,
        image: '/images/stores/app-store.svg',
        target: 'iOS / macOS'
      }
    case 'windows':
      return {
        ...storesLink.windows,
        image: '/images/stores/microsoft-store.svg',
        target: 'Windows'
      }
    case 'linux':
      return {
        ...storesLink.linux,
        image: '/images/stores/snapcraft.svg',
        target: 'Linux'
      }
  }
})

const tip = computed(() => {
  if (!props.availableOnTemplate || !props.availableSoonTemplate) {
    return null
  }
  return (store.value.url ? props.availableOnTemplate : props.availableSoonTemplate).replace('%s', store.value.target)
})
</script>

<template>
  <div class="tooltip" :data-tip="tip">
    <a
      :href="store.url ?? '#download'"
      class="btn btn-lg btn-wide"
      :class="{'btn-disabled': store.url ? null : true}"
      role="button"
    >
      <img :src="store.image" :alt="store.name" class="h-6 w-6">
      {{ store.name }}
    </a>
  </div>
</template>

<style lang="scss" scoped>
.btn-disabled {
  color: rgba(black, 0.3);
  background-color: oklch(var(--b3));
}
</style>
