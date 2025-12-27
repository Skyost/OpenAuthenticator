<script setup lang="ts">
defineProps<{ article: string }>()
const markdownT = useMarkdownT()
</script>

<template>
  <div class="text-center mb-4">
    <h1 v-html="markdownT(`${article}.title`)" />
    <small>
      <em v-html="markdownT(`${article}.lastUpdated`)" />
    </small>
  </div>
</template>
