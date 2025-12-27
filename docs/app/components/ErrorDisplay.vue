<script setup lang="ts">
const props = defineProps<{
  error: any
  changeTitle?: boolean
}>()

const errorCode = computed(() => {
  if (props.error) {
    if (typeof props.error.toString === 'function' && /^-?\d+$/.test(props.error.toString())) {
      return parseInt(props.error.toString())
    }
    if (props.error.statusCode && /^-?\d+$/.test(props.error.statusCode)) {
      return parseInt(props.error.statusCode)
    }
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

const goBack = () => window.history.back()
</script>

<template>
  <div>
    <h1
      class="text-center"
      v-text="title"
    />
    <p>
      You can keep browsing by heading to the <a
        class="underline"
        href="#"
        @click.prevent="goBack"
      >previous page</a> or
      or by going on the <nuxt-link
        class="underline"
        to="/"
      >home page</nuxt-link>.
    </p>
    <p v-if="errorCode === 404">
      If you think something should be here, please <nuxt-link
        class="underline"
        to="/contact/"
      >contact me</nuxt-link>.
    </p>
    <details v-else>
      <pre>{{ error }}</pre>
    </details>
  </div>
</template>
