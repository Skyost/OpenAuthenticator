<script setup lang="ts">
withDefaults(defineProps<{
  center?: boolean
}>(), {
  center: true,
})
</script>

<template>
  <div
    class="blurred-stain"
    :class="{ center: center }"
  />
</template>

<style lang="scss" scoped>
@use 'sass:math';

// noinspection Stylelint
@import 'assets/colors';

.blurred-stain {
  $size: 200px;

  height: $size;
  width: $size;
  background-color: rgba($primary, 0.5);
  border-radius: 50%;
  filter: blur(math.div($size, 2));

  &.center {
    position: absolute;
    top: 50%;
    left: 0;
    right: 0;
    width: 100%;
    transform: translateY(-50%);
    z-index: -1;
  }
}
</style>
