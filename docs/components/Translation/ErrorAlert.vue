<script setup lang="ts">
defineProps<{
  error: any
}>()
</script>

<template>
  <b-alert
    :model-value="true"
    variant="danger"
  >
    <p :class="{ 'mb-0': !error }">
      <icon name="bi:bug-fill" />
      {{ $t('translate.error') }}
    </p>
    <pre
      v-if="error"
      class="mb-0"
    >{{ error }}</pre>
  </b-alert>
</template>
