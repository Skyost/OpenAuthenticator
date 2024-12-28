<script setup lang="ts">
// @ts-expect-error `dot-object` is not a TS library.
import * as dot from 'dot-object'
import {
  generateJson,
  fromJson,
  checkComplete,
  type TranslationFile,
  type TranslationData,
} from '~/components/Translation/Table.vue'
import type { LanguageWithData } from '~/modules/get-info-from-parent'

interface RawTranslationFile {
  fileName: string
  data: Record<string, string>
}

const props = withDefaults(defineProps<{
  originalLanguage?: string
  language: string
}>(), {
  originalLanguage: 'en',
})

const emit = defineEmits<{ update: [] }>()

const {
  data: languagesData,
  status: languagesStatus,
  error: languagesError,
} = await useFetch<Record<string, LanguageWithData>>('/_app/languages.json')

const fetchTranslationFiles = async (language: string): Promise<Record<string, RawTranslationFile>> => {
  const result: Record<string, RawTranslationFile> = {}
  if (!languagesData.value) {
    return result
  }
  if (!(language in languagesData.value)) {
    throw new Error('Language does not exist yet.')
  }
  const files = languagesData.value[language]?.files ?? []
  for (const fileName of files) {
    const content = await $fetch(`/_app/${language}/${fileName}`)
    result[fileName] = {
      fileName: fileName,
      data: dot.dot(content),
    }
  }
  return result
}

const {
  data: files,
  status: filesStatus,
  error: filesError,
} = await useAsyncData<TranslationFile[]>(
  `translation-table-${props.originalLanguage}-${props.language}`,
  async () => {
    const result: TranslationFile[] = []
    const originalLanguage = await fetchTranslationFiles(props.originalLanguage)
    const translation = await fetchTranslationFiles(props.language)
    for (const fileName in originalLanguage) {
      const rawTranslationFile = originalLanguage[fileName]
      const data: TranslationData = {}
      for (const key in rawTranslationFile.data) {
        data[key] = {
          key: key,
          originalValue: rawTranslationFile.data[key],
          translatedValue: translation[fileName]?.data[key] ?? '',
        }
      }
      result.push({
        fileExists: !(!translation[fileName]),
        fileName: rawTranslationFile.fileName,
        targetLanguage: props.language,
        data: data,
        complete: checkComplete(data),
      })
    }
    return result
  },
  {
    watch: [languagesData],
  },
)

const showModal = ref<boolean>(false)
const modalFile = ref<TranslationFile | undefined>()
const openTranslationModal = (file?: TranslationFile | undefined) => {
  modalFile.value = file
  showModal.value = true
}

const load = (index: number) => {
  const element = document.createElement('input')
  element.setAttribute('type', 'file')
  element.setAttribute('accept', 'application/json')
  element.style.display = 'none'
  element.addEventListener(
    'change',
    (event) => {
      // @ts-expect-error Event type doesn't exist in TS.
      const file = event.target?.files[0]
      if (!file) {
        return
      }
      const reader = new FileReader()
      reader.onload = (event) => {
        const content = event.target?.result?.toString()
        if (content && files.value) {
          try {
            const currentData = files.value[index].data
            const data = fromJson(content, (key: string) => currentData[key]?.originalValue)
            files.value[index].data = data
            files.value[index].complete = checkComplete(data)
          }
          catch (ex) {
            console.error(ex)
            alert('An error occurred while loading the given file.')
          }
        }
      }
      reader.readAsText(file)
    },
    false,
  )
  element.click()
}

const download = (index: number) => {
  if (!files.value) {
    return
  }
  const translationFile = files.value[index]
  const element = document.createElement('a')
  element.setAttribute('href', 'data:application/json;charset=utf-8,' + encodeURIComponent(generateJson(translationFile.data)))
  element.setAttribute('download', translationFile.fileName)
  element.style.display = 'none'
  document.body.appendChild(element)
  element.click()
  document.body.removeChild(element)
}
</script>

<template>
  <div v-if="filesStatus === 'pending' || languagesStatus === 'pending'">
    <slot name="loading" />
  </div>
  <div v-else-if="files">
    <slot
      name="title"
      :language="languagesData![language]"
    />
    <b-accordion>
      <b-accordion-item
        v-for="(file, index) in files"
        :id="file.fileName"
        :key="file.fileName"
        :title="file.fileName"
      >
        <template #title>
          <span class="font-monospace">
            <icon
              name="bi:file-earmark-text-fill"
              class="me-2"
            />{{ file.fileName }}
          </span>
        </template>
        <TranslationTable
          v-model="files[index]"
          @update="emit('update')"
        />
        <b-row class="mb-5">
          <b-col class="d-flex align-items-center">
            <b-button-group>
              <b-button
                variant="dark"
                @click="load(index)"
              >
                <icon name="bi:upload" /> {{ $t('translate.accordion.load') }}
              </b-button>
              <b-button
                variant="dark"
                @click="download(index)"
              >
                <icon name="bi:download" /> {{ $t('translate.accordion.save') }}
              </b-button>
            </b-button-group>
          </b-col>
          <b-col class="d-flex align-items-center justify-content-end">
            <b-button
              variant="primary"
              :disabled="!files[index].complete"
              @click="openTranslationModal(files[index])"
            >
              <icon name="bi:check-lg" />
              {{ $t('translate.accordion.submit') }} <span class="font-monospace">{{ file.fileName }}</span>
            </b-button>
          </b-col>
        </b-row>
      </b-accordion-item>
      <translation-modal
        v-model="showModal"
        :file="modalFile"
      />
    </b-accordion>
  </div>
  <div v-else>
    <slot
      name="error"
      :error="filesError ?? languagesError"
    />
  </div>
</template>
