<script setup lang="ts">
withDefaults(defineProps<{
  center?: boolean
}>(), {
  center: true
})
</script>

<template>
  <div
    class="bg-primary pointer-events-none aspect-square rounded-full opacity-20 blur-3xl"
    :class="{'center': center}"
  />
</template>

<style lang="scss" scoped>
.center {
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  transform: translateY(-50%);
  z-index: -1;
}
</style>
