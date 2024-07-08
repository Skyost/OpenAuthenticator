<template>
  <div>
    <div class="outer">
      <div class="dot" />
      <div class="dot" />
      <div class="dot" />
    </div>
    <div class="border bg-white p-5">
      <slot />
    </div>
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  background-color: darken($light, 50%);
  border-radius: 50%;
  margin: 0 4px 0 0;
}

.outer {
  background-color: $dark;
  opacity: 0.9;
  width: 100%;
  margin: 0 auto;
  padding: 10px;
  border-radius: 7px 7px 0 0;
}
</style>
