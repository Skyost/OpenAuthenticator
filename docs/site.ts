export interface StoreInfo {
  name: string
  url: string | null
}

export type OS = 'android' | 'darwin' | 'windows' | 'linux'

export const storesLink: Record<OS, StoreInfo> = {
  android: {
    name: 'Google Play',
    url: 'https://play.google.com/store/apps/details?id=app.openauthenticator',
  },
  darwin: {
    name: 'App Store',
    url: 'https://apps.apple.com/app/id6479272927',
  },
  windows: {
    name: 'Microsoft Store',
    url: 'https://www.microsoft.com/store/apps/9PB8HFZFKLT4',
  },
  linux: {
    name: 'Snapcraft',
    url: 'https://snapcraft.io/open-authenticator',
  },
}

export const siteMeta = {
  name: 'Open Authenticator',
  description: 'Secure your online accounts with a free, open-source and lovely-crafted app.',
  url: 'https://openauthenticator.app',
  github: 'https://github.com/Skyost/OpenAuthenticator',
}

export const contactPostUrl = 'https://script.google.com/macros/s/AKfycbxjmOxUnOADCgyII87ac6vas5Y9671WpHAWLAYFjSn05dLmkXdUMl9q-o6gTwVHfgPsVg/exec'
export const recaptchaKey = '6Lem_AEqAAAAAJvAC-NfFRdggB5oHSzL6fSF3BY4'
