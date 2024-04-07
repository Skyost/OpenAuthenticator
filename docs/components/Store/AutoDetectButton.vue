<script setup lang="ts">
import { storesLink, type OS } from '~/site'

defineProps<{
  moreButton?: string,
  loadingText?: string,
  availableSoonTemplate?: string,
  availableOnTemplate?: string
}>()

const os = computed<OS | null>(() => {
  if (!process.client) {
    return null
  }
  const clientStrings: Record<OS, RegExp> = {
    windows: /(Windows 10.0|Windows NT 10.0|Windows 8.1|Windows NT 6.3|Windows 8|Windows NT 6.2|Windows 7|Windows NT 6.1|Windows Vista|Windows NT 6.0|Windows Server 2003|Windows NT 5.2|Windows NT 5.1|Windows XP|Windows NT 5.0|Windows 2000|Win 9x 4.90|Windows ME|Windows 98|Win98|Windows 95|Win95|Windows_95|Windows NT 4.0|WinNT4.0|WinNT|Windows CE|Win16|OS\/2)/,
    android: /Android/,
    darwin: /(iPhone|iPad|iPod|Macintosh|Mac OS X|Mac OS|MacPPC|MacIntel|Mac_PowerPC)/,
    linux: /(Linux|X11(?!.*CrOS)|OpenBSD|SunOS|CrOS|QNX|UNIX|BeOS)/
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
  <client-only placeholder-tag="span" :placeholder="loadingText">
    <div v-if="os">
      <div class="text-center xl:text-start">
        <store-button
          class="mb-8"
          :os="os"
          :available-on-template="availableOnTemplate"
          :available-soon-template="availableSoonTemplate"
        />
      </div>
      <div v-if="moreButton" tabindex="0" class="collapse collapse-arrow bg-black">
        <input type="checkbox">
        <div class="collapse-title">
          {{ moreButton }}
        </div>
        <div class="collapse-content flex justify-evenly flex-col gap-5 xl:flex-row">
          <store-button
            v-for="(storeOs, index) in oSToShow"
            :key="`store-${index}`"
            :os="storeOs"
            :available-on-template="availableOnTemplate"
            :available-soon-template="availableSoonTemplate"
          />
        </div>
      </div>
    </div>
    <div v-else>
      <store-button
        v-for="(storeOs, index) in oSToShow"
        :key="`store-${index}`"
        class="mx-4"
        :os="storeOs"
        :available-on-template="availableOnTemplate"
        :available-soon-template="availableSoonTemplate"
      />
    </div>
  </client-only>
</template>
