<script setup lang="ts">
const props = defineProps<{
  error: any,
  changeTitle?: boolean
}>()

const errorCode = computed(() => {
  if (/^-?\d+$/.test(props.error.toString())) {
    return parseInt(props.error.toString())
  }
  if (Object.prototype.hasOwnProperty.call(props.error, 'statusCode')) {
    return parseInt(props.error.statusCode)
  }
  return null
})

const title = computed(() => {
  if (errorCode.value === 404) {
    return 'Page not found !'
  }
  if (errorCode.value) {
    return `Error ${errorCode.value}`
  }
  return 'Error'
})
</script>

<template>
  <div>
    <h1 class="text-center" v-text="title" />
    <p>
      You can keep browsing by heading to the <a class="underline" href="javascript:history.back()">previous page</a> or
      or by going on the <nuxt-link class="underline" to="/">home page</nuxt-link>.
      <span v-if="errorCode === 404">
        If you think something should be here, please <nuxt-link class="underline" to="/contact/">contact me</nuxt-link>.
      </span>
    </p>
  </div>
</template>
