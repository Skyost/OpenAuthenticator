<script setup lang="ts">
const i18nHead = useLocaleHead({
  addSeoAttributes: {
    canonicalQueries: ['foo'],
  },
})
useHead({
  htmlAttrs: {
    lang: i18nHead.value.htmlAttrs!.lang,
  },
  link: [...(i18nHead.value.link || [])],
  meta: [...(i18nHead.value.meta || [])],
})
</script>

<template>
  <div>
    <page-navbar />
    <slot />
    <page-footer />
  </div>
</template>

<style lang="scss">
h1, h2, h3, h4 {
  font-weight: lighter !important;

  strong {
    font-weight: bold !important;
  }
}

article {
  padding-top: 3rem !important;
  padding-bottom: 3rem !important;

  h1 {
    font-weight: bold !important;
  }
}

ul {
  list-style-type: '– ';
  padding-left: 1em;
}

.btn-primary, .btn-success {
  color: white !important;
}

.btn .iconify {
  vertical-align: -0.15em;
}
</style>
