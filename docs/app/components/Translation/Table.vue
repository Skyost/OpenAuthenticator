<script lang="ts">
import dot from 'dot-object'

export interface TranslationEntry {
  key: string
  originalValue: string
  translatedValue: string
}

export type TranslationData = Record<string, TranslationEntry>

export interface TranslationFile {
  fileName: string
  fileExists: boolean
  targetLanguage: string
  data: TranslationData
  complete: boolean
}

export const checkComplete = (data: TranslationData): boolean => {
  for (const key in data) {
    if (!data[key]?.translatedValue) {
      return false
    }
  }
  return true
}

export const fromJson = (json: string, getOriginalValue: (key: string) => string | undefined): TranslationData => {
  const result: TranslationData = {}
  const parsedJson = dot.dot(JSON.parse(json))
  for (const key in parsedJson) {
    const originalValue = getOriginalValue(key)
    if (originalValue) {
      result[key] = {
        key: key,
        translatedValue: parsedJson[key],
        originalValue: originalValue,
      }
    }
  }
  return result
}

export const generateJson = (data: TranslationData): string => {
  const dottedObject: Record<string, string> = {}
  for (const key in data) {
    const entry = data[key]!
    const translatedValue = entry.translatedValue
    if (translatedValue.trim().length > 0) {
      dottedObject[entry.key] = translatedValue
    }
  }
  return JSON.stringify(dot.object(dottedObject), null, 2)
}
</script>

<script setup lang="ts">
const model = defineModel<TranslationFile>()

const emit = defineEmits<{
  (event: 'update:modelValue', file: TranslationFile): void
}>()

const onUpdate = (key: string, value: string): void => {
  const file: TranslationFile | undefined = model.value
  if (!file || !file.data[key]) {
    return
  }
  file.data[key].translatedValue = value
  if (value.length === 0) {
    file.complete = false
  }
  else if (!file.complete) {
    file.complete = checkComplete(file.data)
  }
  emit('update:modelValue', file)
}
</script>

<template>
  <b-row
    v-if="model"
    responsive
  >
    <b-col
      class="title"
      sm="12"
      md="6"
    >
      <span>
        <icon name="bi:paragraph" /> {{ $t('translate.table.originalText') }}
      </span>
    </b-col>
    <b-col
      class="title"
      sm="12"
      md="6"
    >
      <span class="font-bold">
        <icon name="bi:translate" /> {{ $t('translate.table.translation') }}
      </span>
    </b-col>
    <template
      v-for="key in Object.keys(model.data)"
      :key="`${model.fileName}-${key}`"
    >
      <b-col
        xs="12"
        md="6"
        class="pb-3"
      >
        <b-form-group>
          <template #description>
            <span class="font-monospace"><icon name="bi:chevron-right" />{{ key }}</span>
          </template>
          <client-only>
            <b-form-textarea
              :model-value="model.data[key]!.originalValue"
              disabled
              no-resize
            />
            <template #fallback>
              <pre>
                {{ model.data[key]!.originalValue }}
              </pre>
            </template>
          </client-only>
        </b-form-group>
      </b-col>
      <b-col
        xs="12"
        md="6"
        class="pb-4"
      >
        <client-only>
          <b-form-textarea
            :model-value="model.data[key]!.translatedValue"
            :placeholder="model.data[key]!.originalValue"
            @update:model-value="value => onUpdate(key, value?.toString() ?? '')"
          />
          <template #fallback>
            <pre>
                {{ model.data[key]!.translatedValue }}
              </pre>
          </template>
        </client-only>
      </b-col>
    </template>
  </b-row>
</template>

<style lang="scss" scoped>
@import 'assets/bootstrap-mixins';

.title {
  font-weight: bold;
  border-bottom: 1px solid var(--bs-secondary-bg);
  padding: 6px;
  margin-bottom: 10px;

  @include media-breakpoint-down(md) {
    display: none !important;
  }
}
</style>
