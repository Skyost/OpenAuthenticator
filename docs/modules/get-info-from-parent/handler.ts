import { storageKey } from './common'
import { defineEventHandler, createError } from 'h3'
import { useStorage } from 'nitropack/runtime/internal/storage'

export default defineEventHandler(async (event) => {
  const params = event.context.params
  const file = params?.file
  const directory = params?.directory
  if (!file) {
    throw createError({ status: 404 })
  }

  const filePath = directory ? `${directory}/${file}` : file
  const content = await useStorage(`assets:${storageKey}`).getItem(filePath)
  if (!content) {
    throw createError({ status: 404 })
  }
  return content
})
