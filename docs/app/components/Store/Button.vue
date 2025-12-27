<script setup lang="ts">
import { type StoreInfo, type OS, stores } from '~/site'

const props = defineProps<{
  os: OS
  store: StoreInfo
  availableSoonText?: (os: string) => string
  availableOnText?: (os: string) => string
}>()

interface ExtendedStoreInfo extends StoreInfo {
  target: string
}

const extendedStoreInfo = computed<ExtendedStoreInfo>(() => {
  let target = 'Unknown'
  switch (props.os) {
    case 'android':
      target = 'Android'
      break
    case 'darwin':
      target = 'iOS / macOS'
      break
    case 'windows':
      target = 'Windows'
      break
    case 'linux':
      target = 'Linux'
      break
  }
  return {
    ...props.store,
    target,
  }
})

const tip = computed(() => {
  if (!props.availableOnText || !props.availableSoonText) {
    return null
  }
  let tip = (extendedStoreInfo.value.url ? props.availableOnText : props.availableSoonText)(extendedStoreInfo.value.target)
  const info = stores[props.os]
  if (info && info.length > 1) {
    tip += ` (${props.store.name})`
  }
  return tip
})
</script>

<template>
  <div
    v-b-tooltip="tip"
    class="store-button-card"
  >
    <b-button
      :href="extendedStoreInfo.url ?? '#download'"
      :size="'lg'"
      class="store-button"
      :class="{ disabled: extendedStoreInfo.url ? null : true }"
      variant="light"
    >
      <img
        :src="`/images/stores/${extendedStoreInfo.id}.svg`"
        :alt="extendedStoreInfo.name"
        class="me-1"
      >
      <span>{{ extendedStoreInfo.name }}</span>
    </b-button>
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';

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

    @include media-breakpoint-down(sm) {
      font-size: 1rem;
    }
  }
}
</style>
