export interface StoreInfo {
  name: string
  url: string | null
}

export type OS = 'android' | 'darwin' | 'windows' | 'linux'

export const storesLink: Record<OS, StoreInfo> = {
  android: {
    name: 'Google Play',
    url: null, // 'https://play.google.com/store/apps/details?id=app.openauthenticator',
  },
  darwin: {
    name: 'App Store',
    url: 'https://apps.apple.com/app/id6479272927',
  },
  windows: {
    name: 'Microsoft Store',
    url: null, // 'https://www.microsoft.com/store/apps/9PB8HFZFKLT4',
  },
  linux: {
    name: 'Snapcraft',
    url: null,
  },
}

export const siteMeta = {
  name: 'Open Authenticator',
  description: 'Secure your online accounts with a free, open-source and lovely-crafted app.',
  url: 'https://openauthenticator.app',
  github: 'https://github.com/Skyost/OpenAuthenticator',
}

export const contactPostUrl = 'https://script.google.com/macros/s/AKfycbzXs_vsLAX5jStwqH9mIVKr8mr7L0C3wsVC4net9BlvhbYFR97UkE9tRIsT2z07REKjQQ/exec'
export const recaptchaKey = '6Lem_AEqAAAAAJvAC-NfFRdggB5oHSzL6fSF3BY4'
