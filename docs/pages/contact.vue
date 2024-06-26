<script setup lang="ts">
import { load } from 'recaptcha-v3'
import { contactPostUrl, recaptchaKey } from '~/site'

enum FormState {
  incomplete,
  complete,
  sending,
  error,
  success
}

const accountDeletion = 'accountDeletion'
const subjects = [accountDeletion, 'moreInfoNeeded', 'commercial', 'other']

const currentName = ref<string>('')
const currentEmail = ref<string>('')
const currentSubject = ref<string>(accountDeletion)
const currentMessage = ref<string>('')
const currentState = ref<FormState>(FormState.incomplete)

const formSubmitEnabled = computed(() => currentState.value === FormState.complete)
const formEnabled = computed(() => currentState.value === FormState.incomplete || formSubmitEnabled.value)

watch(currentName, () => currentState.value = isValid() ? FormState.complete : FormState.incomplete)
watch(currentEmail, () => currentState.value = isValid() ? FormState.complete : FormState.incomplete)
watch(currentSubject, () => currentState.value = isValid() ? FormState.complete : FormState.incomplete)
watch(currentMessage, () => currentState.value = isValid() ? FormState.complete : FormState.incomplete)

const isValid = () => {
  if (!currentName.value || currentName.value.length === 0) {
    return false
  }
  if (!currentEmail.value || currentEmail.value.length === 0 || !(/\S+@\S+\.\S+/.test(currentEmail.value))) {
    return false
  }
  if (subjects.indexOf(currentSubject.value) === -1) {
    return false
  }
  return currentSubject.value === accountDeletion || (currentMessage.value && currentMessage.value.length > 0);
}

const onFormSubmit = async () => {
  currentState.value = FormState.sending
  try {
    const recaptcha = await load(recaptchaKey, {autoHideBadge: true})
    const token = await recaptcha.execute('contact')
    await fetch(
      contactPostUrl,
      {
        method: 'post',
        headers: {
          'Content-Type': 'text/plain;charset=utf-8',
        },
        body: JSON.stringify({
          name: currentName.value,
          email: currentEmail.value,
          subject: currentSubject.value,
          message: currentSubject.value === accountDeletion ? '' : currentMessage.value,
          gCaptchaResponse: token
        })
      }
    )
    currentState.value = FormState.success
  } catch (_) {
    currentState.value = FormState.error
  }
}
</script>

<template>
  <article>
    <page-head :title="$t('contact.title')" />
    <div class="relative flex max-w-[100vw] items-center justify-center overflow-hidden p-10 md:p-20 pb-0 md:pb-0">
      <div class="relative flex max-w-[100rem] flex-col items-center justify-center xl:flex-row xl:gap-20">
        <div class="relative z-[1] w-full py-10 prose max-w-none">
          <h1 class="text-center leading-none xl:text-start">
            {{ $t('contact.title') }}
          </h1>
          <p class="text-base-content/70 text-center xl:text-start my-10" v-html="$t('contact.description')" />
        </div>
        <div>
          <img
            src="/images/contact/plane.svg"
            alt="Paper plan"
            class="min-w-48 max-w-96"
            title="Image credit : juicy_fish (freepik.com/author/juicy-fish)"
          >
        </div>
      </div>
    </div>
    <div class="relative flex max-w-[100vw] items-center justify-center overflow-hidden p-10 md:p-20 xl:pt-0">
      <form
        class="max-w-[100rem] w-full space-y-8"
        :action="contactPostUrl"
        method="post"
        @submit.prevent="onFormSubmit"
      >
        <div>
          <label
            for="name"
            class="block mb-2 text-sm font-medium text-gray-900"
          >
            {{ $t('contact.form.name.label') }}
          </label>
          <input
            id="name"
            v-model="currentName"
            type="text"
            class="shadow-sm bg-gray-50 border border-primary-300 text-gray-900 text-sm rounded-lg block w-full p-2.5"
            :placeholder="$t('contact.form.name.placeholder')"
            :disabled="!formEnabled"
            required
          >
        </div>
        <div>
          <label
            for="email"
            class="block mb-2 text-sm font-medium text-gray-900"
          >
            {{ $t('contact.form.email.label') }}
          </label>
          <input
            id="email"
            v-model="currentEmail"
            type="email"
            class="shadow-sm bg-gray-50 border border-primary-300 text-gray-900 text-sm rounded-lg block w-full p-2.5"
            :placeholder="$t('contact.form.email.placeholder')"
            :disabled="!formEnabled"
            required
          >
        </div>
        <div>
          <label for="subject" class="block mb-2 text-sm font-medium text-gray-900">
            {{ $t('contact.form.subject.label') }}
          </label>
          <select
            id="subject"
            v-model="currentSubject"
            class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg block w-full p-2.5"
            :disabled="!formEnabled"
            required
          >
            <option
              v-for="(subject, index) in subjects"
              :key="`contact-subject-${index}`"
              :value="subject"
            >
              {{ $t(`contact.form.subject.options.${subject}`) }}
            </option>
          </select>
        </div>
        <div
          v-if="currentSubject !== accountDeletion"
          class="sm:col-span-2"
        >
          <label for="message" class="block mb-2 text-sm font-medium text-gray-900">
            {{ $t('contact.form.message.label') }}
          </label>
          <textarea
            id="message"
            v-model="currentMessage"
            rows="6"
            class="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg shadow-sm border border-gray-300"
            :placeholder="$t('contact.form.message.placeholder')"
            :disabled="!formEnabled"
          />
        </div>
        <p
          v-if="currentState === FormState.success || currentState === FormState.error"
          class="mb-0 text-sm"
          :class="{'text-red-700': currentState === FormState.error, 'text-green-700': currentState === FormState.success }"
        >
          {{ $t(`contact.form.${currentState === FormState.error ? "error" : "success"}`) }}
        </p>
        <button
          type="submit"
          class="btn btn-primary"
          :class="{ 'cursor-not-allowed': !formSubmitEnabled }"
          :disabled="!formSubmitEnabled"
        >
          <icon name="bi:send" class="h-6 w-6" /> {{ $t('contact.form.send') }}
        </button>
      </form>
    </div>
  </article>
</template>
