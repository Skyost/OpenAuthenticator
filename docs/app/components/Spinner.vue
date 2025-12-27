<script setup lang="ts">
withDefaults(defineProps<{
  padding?: boolean
}>(), {
  padding: true,
})
</script>

<template>
  <div
    class="text-center"
    :class="{ 'p-5': padding }"
  >
    <b-spinner variant="primary" />
  </div>
</template>
