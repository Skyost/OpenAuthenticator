<script setup lang="ts">
import { load } from 'recaptcha-v3'
import { contactPostUrl, recaptchaKey } from '~/site'

enum FormState {
  incomplete,
  complete,
  sending,
  error,
  success,
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
  return currentSubject.value === accountDeletion || (currentMessage.value && currentMessage.value.length > 0)
}

const onFormSubmit = async () => {
  currentState.value = FormState.sending
  try {
    const recaptcha = await load(recaptchaKey, { autoHideBadge: true })
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
          gCaptchaResponse: token,
        }),
      },
    )
    currentState.value = FormState.success
  }
  catch (_) {
    currentState.value = FormState.error
  }
}
</script>

<template>
  <b-container class="pt-5 pb-5">
    <page-head :title="$t('contact.title')" />
    <b-row>
      <b-col
        sm="12"
        md="7"
        lg="9"
      >
        <h1>{{ $t('contact.title') }}</h1>
        <p v-html="$t('contact.description')" />
      </b-col>
      <b-col
        sm="12"
        md="5"
        lg="3"
        class="d-flex align-items-center"
      >
        <img
          class="plane-icon"
          src="/images/contact/plane.svg"
          alt="Paper plan"
          title="Image credit : juicy_fish (freepik.com/author/juicy-fish)"
        >
      </b-col>
    </b-row>
    <client-only
      fallback-tag="em"
      fallback="Loading form..."
    >
      <b-form
        :action="contactPostUrl"
        class="pt-3 pb-3"
        method="post"
        @submit.prevent="onFormSubmit"
      >
        <b-form-group
          class="form-group"
          :label="$t('contact.form.name.label')"
          label-for="name"
        >
          <b-form-input
            id="name"
            v-model="currentName"
            type="text"
            :placeholder="$t('contact.form.name.placeholder')"
            :disabled="!formEnabled"
            required
          />
        </b-form-group>
        <b-form-group
          class="form-group"
          :label="$t('contact.form.email.label')"
          label-for="name"
        >
          <b-form-input
            id="email"
            v-model="currentEmail"
            type="email"
            :placeholder="$t('contact.form.email.placeholder')"
            :disabled="!formEnabled"
            required
          />
        </b-form-group>
        <b-form-group
          class="form-group"
          :label="$t('contact.form.subject.label')"
          label-for="subject"
        >
          <b-form-select
            id="subject"
            v-model="currentSubject"
            :disabled="!formEnabled"
            required
          >
            <b-form-select-option
              v-for="(subject, index) in subjects"
              :key="`contact-subject-${index}`"
              :value="subject"
            >
              {{ $t(`contact.form.subject.options.${subject}`) }}
            </b-form-select-option>
          </b-form-select>
        </b-form-group>
        <b-form-group
          v-if="currentSubject !== accountDeletion"
          class="form-group"
          :label="$t('contact.form.message.label')"
          label-for="message"
        >
          <b-form-textarea
            id="message"
            v-model="currentMessage"
            rows="6"
            :placeholder="$t('contact.form.message.placeholder')"
            :disabled="!formEnabled"
          />
        </b-form-group>
        <b-button
          class="mt-2"
          variant="primary"
          type="submit"
          :disabled="!formSubmitEnabled"
        >
          <icon name="bi:send" /> {{ $t('contact.form.send') }}
        </b-button>
      </b-form>
    </client-only>
    <b-alert
      :model-value="currentState === FormState.error"
      class="mb-5"
      variant="danger"
    >
      {{ $t('contact.form.error') }}
    </b-alert>
    <b-alert
      :model-value="currentState === FormState.success"
      class="mb-5"
      variant="success"
    >
      {{ $t('contact.form.success') }}
    </b-alert>
  </b-container>
</template>

<style lang="scss" scoped>
.plane-icon {
  max-width: 100%;
}

.form-group {
  margin-top: 10px;
  margin-bottom: 10px;
}
</style>
