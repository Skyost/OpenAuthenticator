<template>
  <div class="mobile-phone">
    <div class="brove">
      <div class="position-relative">
        <span class="speaker" />
      </div>
    </div>
    <div class="screen">
      <slot />
    </div>
  </div>
</template>

<style scoped lang="scss">
@import 'assets/bootstrap-mixins';

$padding: 10px;
$original-width: 330px;
$original-height: 600px;
$lg-width: 300px;
$md-width: 200px;

.mobile-phone {
  position: relative;
  margin: 0 auto;
  padding: $padding;
  box-shadow: 0 0 20px #e2e2e2;
  border-radius: 30px;
  background-color: #484949;
  width: $original-width;
  height: $original-height;

  @include media-breakpoint-down(lg) {
    width: $lg-width;
    height: calc($lg-width * $original-height / $original-width);
  }

  @include media-breakpoint-down(md) {
    width: $md-width;
    height: calc($md-width * $original-height / $original-width);
  }
}

.screen {
  width: 100%;
  height: 100%;
  background: #f2f2f2;
  border-radius: 30px;
  overflow-y: hidden;
}

.brove {
  $brove-original-width: 150px;
  $brove-original-height: 20px;

  width: $brove-original-width;
  height: $brove-original-height;
  background: #484949;
  position: absolute;
  top: $padding;
  border-radius: 0 0 20px 20px;
  left: 50%;
  transform: translateX(-50%);

  @include media-breakpoint-down(lg) {
    $width: calc($brove-original-width * $lg-width / $original-width);

    width: $width;
    height: calc($width * $brove-original-height / $brove-original-width);
  }

  @include media-breakpoint-down(md) {
    $width: calc($brove-original-width * $md-width / $original-width);

    width: $width;
    height: calc($width * $brove-original-height / $brove-original-width);
  }
}

.speaker {
  $speaker-original-width: 60px;
  $speaker-original-height: 5px;

  width: $speaker-original-width;
  height: $speaker-original-height;
  position: absolute;
  top: calc(50% + #{$speaker-original-height});
  left: 50%;
  transform: translate(-50%, -50%);
  background-color: black;
  display: block;
  border-radius: 20px;

  @include media-breakpoint-down(lg) {
    $width: calc($speaker-original-width * $lg-width / $original-width);
    $height: calc($width * $speaker-original-height / $speaker-original-width);

    width: $width;
    height: $height;
    top: calc(50% + $height);
  }

  @include media-breakpoint-down(md) {
    $width: calc($speaker-original-width * $md-width / $original-width);
    $height: calc($width * $speaker-original-height / $speaker-original-width);

    width: $width;
    height: $height;
    top: calc(50% + $height);
  }
}
</style>
