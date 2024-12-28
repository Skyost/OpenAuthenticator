<script setup lang="ts">
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'
import json from 'highlight.js/lib/languages/json'

const props = withDefaults(defineProps<{
  content: string
  copyText?: string
}>(), {
  copyText: 'Copy to clipboard',
})

onMounted(() => hljs.registerLanguage('json', json))

const clipboardIcon = ref()

let changeIconTimeout: NodeJS.Timeout | null = null
const copyToClipboard = async () => {
  if (changeIconTimeout) {
    clearTimeout(changeIconTimeout)
    changeIconTimeout = null
  }
  try {
    await navigator.clipboard.writeText(props.content)
    clipboardIcon.value.classList.add('success')
  }
  catch (ex) {
    console.error(ex)
    clipboardIcon.value.classList.add('error')
  }
  changeIconTimeout = setTimeout(() => {
    clipboardIcon.value.classList.remove('success')
    clipboardIcon.value.classList.remove('error')
  }, 1000)
}
</script>

<template>
  <div class="code">
    <span
      ref="clipboardIcon"
      :title="copyText"
      class="copy-icon"
      @click="copyToClipboard"
    >
      <icon
        class="idle-icon"
        name="bi:clipboard"
      />
      <icon
        class="success-icon"
        name="bi:clipboard-check"
      />
      <icon
        class="error-icon"
        name="bi:clipboard-x"
      />
    </span>
    <pre><code
      class="language-json"
      v-html="hljs.highlight(content, { language: 'json' }).value"
    /></pre>
  </div>
</template>

<style lang="scss" scoped>
@import 'assets/colors';

.code {
  background-color: $light;
  padding: 0.375rem 0.75rem;
  border-radius: var(--bs-border-radius);
  position: relative;

  .copy-icon {
    position: absolute;
    top: 0.375rem;
    right: 0.75rem;
    cursor: pointer;

    .success-icon, .error-icon {
      display: none;
    }

    &.success, &.error {
      cursor: auto;
      opacity: 0.7;

      .idle-icon {
        display: none;
      }
    }

    &.success .success-icon, &.error .error-icon {
      display: inline-block;
    }
  }

  pre {
    white-space: pre-wrap;
    margin-bottom: 0;
  }
}
</style>
