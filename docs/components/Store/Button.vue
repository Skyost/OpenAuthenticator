<script setup lang="ts">
import { storesLink, type StoreInfo, type OS } from '~/site'

const props = defineProps<{
  os: OS
  availableSoonTemplate?: string
  availableOnTemplate?: string
}>()

interface ExtendedStoreInfo extends StoreInfo {
  image: string
  target: string
}

const store = computed<ExtendedStoreInfo>(() => {
  switch (props.os) {
    case 'android':
      return {
        ...storesLink.android,
        image: '/images/stores/google-play.svg',
        target: 'Android',
      }
    case 'darwin':
      return {
        ...storesLink.darwin,
        image: '/images/stores/app-store.svg',
        target: 'iOS / macOS',
      }
    case 'windows':
      return {
        ...storesLink.windows,
        image: '/images/stores/microsoft-store.svg',
        target: 'Windows',
      }
    case 'linux':
      return {
        ...storesLink.linux,
        image: '/images/stores/snapcraft.svg',
        target: 'Linux',
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
  <div
    v-b-tooltip="tip"
    class="store-button-card"
  >
    <b-button
      :href="store.url ?? '#download'"
      :size="'lg'"
      class="store-button"
      :class="{ disabled: store.url ? null : true }"
      variant="light"
    >
      <div>
        <img
          :src="store.image"
          :alt="store.name"
          class="me-1"
        >
        {{ store.name }}
      </div>
    </b-button>
  </div>
</template>

<style lang="scss" scoped>
.store-button-card {
  max-width: 300px;
  width: 100%;
  display: inline-block;

  .store-button {
    min-height: 3em;
    display: flex;
    align-items: center;
    justify-content: center;

    img {
      height: 1em;
      vertical-align: -0.1em;
      padding-right: 0.2em;
    }

    &.disabled {
      color: rgba(black, 0.3);
    }
  }
}
</style>
