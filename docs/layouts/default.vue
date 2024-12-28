<script setup lang="ts">
const head = useLocaleHead({
  addDirAttribute: true,
  identifierAttribute: 'id',
  addSeoAttributes: true,
})
</script>

<template>
  <Html
    :lang="head.htmlAttrs?.lang"
    :dir="head.htmlAttrs?.dir"
  >
    <page-navbar />
    <slot />
    <page-footer />
  </Html>
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
