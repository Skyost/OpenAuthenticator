export interface StoreInfo {
  name: string,
  url: string | null
}

export type OS = 'android' | 'darwin' | 'windows' | 'linux'

export const storesLink: Record<OS, StoreInfo> = {
  android: {
    name: 'Google Play',
    url: 'https://play.google.com/store/apps/details?id=app.openauthenticator'
  },
  darwin: {
    name: 'App Store',
    url: 'https://apps.apple.com/app/id6479272927'
  },
  windows: {
    name: 'Microsoft Store',
    url: null
  },
  linux: {
    name: 'Snapcraft',
    url: null
  }
}

export const siteMeta = {
  name: 'Open Authenticator',
  description: 'Secure your online accounts with a free, open-source and lovely-crafted app.',
  url: 'https://openauthenticator.app',
  github: 'https://github.com/Skyost/OpenAuthenticator'
}
