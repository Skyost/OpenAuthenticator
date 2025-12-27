<script setup lang="ts">
defineProps<{ article: string }>()
</script>

<template>
  <div class="text-center mb-4">
    <h1 v-html="$t(`${article}.title`)" />
    <small>
      <em v-html="$t(`${article}.lastUpdated`)" />
    </small>
  </div>
</template>
