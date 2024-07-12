<script setup lang="ts">
import { storesLink, type OS } from '~/site'

defineProps<{
  moreButton?: string
  loadingText?: string
  availableSoonTemplate?: string
  availableOnTemplate?: string
}>()

const os = computed<OS | null>(() => {
  if (!import.meta.client) {
    return null
  }
  const clientStrings: Record<OS, RegExp> = {
    windows: /(Windows 10.0|Windows NT 10.0|Windows 8.1|Windows NT 6.3|Windows 8|Windows NT 6.2|Windows 7|Windows NT 6.1|Windows Vista|Windows NT 6.0|Windows Server 2003|Windows NT 5.2|Windows NT 5.1|Windows XP|Windows NT 5.0|Windows 2000|Win 9x 4.90|Windows ME|Windows 98|Win98|Windows 95|Win95|Windows_95|Windows NT 4.0|WinNT4.0|WinNT|Windows CE|Win16|OS\/2)/,
    android: /Android/,
    darwin: /(iPhone|iPad|iPod|Macintosh|Mac OS X|Mac OS|MacPPC|MacIntel|Mac_PowerPC)/,
    linux: /(Linux|X11(?!.*CrOS)|OpenBSD|SunOS|CrOS|QNX|UNIX|BeOS)/,
  }
  for (const os in clientStrings) {
    const regex = clientStrings[os as OS]
    if (regex.test(navigator.userAgent)) {
      return os as OS
    }
  }
  return null
})

const oSToShow = computed<OS[]>(() => {
  const result: OS[] = []
  for (const storeOs in storesLink) {
    if (storeOs !== os.value) {
      result.push(storeOs as OS)
    }
  }
  return result
})
</script>

<template>
  <client-only
    placeholder-tag="span"
    :placeholder="loadingText"
  >
    <div v-if="os">
      <div class="text-center w-100">
        <store-button
          class="mb-4"
          :os="os"
          :available-on-template="availableOnTemplate"
          :available-soon-template="availableSoonTemplate"
        />
      </div>
      <b-accordion v-if="moreButton">
        <b-accordion-item
          :title="moreButton"
          class="border-black text-center"
          body-class="bg-black text-white"
          button-class="accordion-black-button bg-black text-white"
        >
          <div class="accordion-content-buttons">
            <div
              v-for="(storeOs, index) in oSToShow"
              :key="`store-${index}`"
              class="accordion-content-button"
            >
              <store-button
                :os="storeOs"
                :available-on-template="availableOnTemplate"
                :available-soon-template="availableSoonTemplate"
              />
            </div>
          </div>
        </b-accordion-item>
      </b-accordion>
    </div>
    <div v-else>
      <store-button
        v-for="(storeOs, index) in oSToShow"
        :key="`store-${index}`"
        :os="storeOs"
        :available-on-template="availableOnTemplate"
        :available-soon-template="availableSoonTemplate"
      />
    </div>
  </client-only>
</template>

<style lang="scss">
.accordion-black-button {
  --bs-accordion-border-color: black;
  --bs-accordion-btn-focus-box-shadow: 0 0 0 0.25rem #ffffff25;

  &::after {
    --bs-accordion-btn-icon: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='none' stroke='white' stroke-linecap='round' stroke-linejoin='round'%3e%3cpath d='M2 5L8 11L14 5'/%3e%3c/svg%3e");
    --bs-accordion-btn-active-icon: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='none' stroke='white' stroke-linecap='round' stroke-linejoin='round'%3e%3cpath d='M2 5L8 11L14 5'/%3e%3c/svg%3e");
  }
}
</style>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';

.accordion-content-buttons {
  display: flex;
  justify-content: space-evenly;
  gap: 20px;

  .accordion-content-button {
    flex: 1;
  }

  @include media-breakpoint-down(lg) {
    flex-direction: column;
  }
}
</style>
