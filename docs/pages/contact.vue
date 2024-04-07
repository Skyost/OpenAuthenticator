<script setup lang="ts">
import { siteMeta } from '~/site'
</script>

<template>
  <article>
    <page-head :title="$t('contact.contactButtons.title')" />
    <div class="relative flex max-w-[100vw] items-center justify-center overflow-hidden p-10 md:p-20">
      <div class="relative flex max-w-[100rem] flex-col items-center justify-center xl:flex-row xl:gap-20">
        <div class="relative z-[1] w-full py-10 prose max-w-none">
          <h1 class="text-center leading-none xl:text-start">
            {{ $t('contact.title') }}
          </h1>
          <p class="text-base-content/70 text-center xl:text-start my-10" v-html="$t('contact.description')" />
          <div class="inline-flex w-full flex-col items-stretch justify-center gap-2 px-4 md:flex-row xl:justify-start xl:px-0">
            <a :href="`${siteMeta.github}/issues/new`" class="btn btn-lg btn-primary btn-wide">
              <icon name="bi:github" class="h-6 w-6" /> {{ $t('contact.contactButtons.github') }}
            </a>
            <a href="https://skyost.eu/#contact" class="btn btn-lg btn-wide">
              <icon name="bi:globe" class="h-6 w-6" /> {{ $t('contact.contactButtons.website') }}
            </a>
          </div>
        </div>
        <div>
          <img
            src="/images/contact/plane.svg"
            alt="Paper plan"
            class="min-w-48 max-w-96"
            title="Image credit : juicy_fish (freepik.com/author/juicy-fish)"
          >
        </div>
      </div>
    </div>
  </article>
</template>
