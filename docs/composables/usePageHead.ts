import { siteMeta } from '~/site'

/**
 * Configurable parameters for `usePageHead`.
 */
export interface PageHead {
  /**
   * The page title.
   */
  title?: string
  /**
   * The page description.
   */
  description?: string
  /**
   * The OpenGraph image.
   */
  openGraphImage?: string
  /**
   * The Twitter card to use.
   */
  twitterCard?: 'summary' | 'summary_large_image' | 'app' | 'player'
  /**
   * The Twitter image.
   */
  twitterImage?: string
}

/**
 * Adds the specified tags to the page head.
 * @param {PageHead} pageHead The parameters to use.
 */
export const usePageHead = (pageHead?: PageHead) => {
  const head: PageHead = { ...(pageHead ?? {}) }
  head.title ??= siteMeta.name
  if (head.title !== siteMeta.name) {
    head.title = `${head.title} | ${siteMeta.name}`
  }
  head.description ??= siteMeta.description
  head.openGraphImage ??= `${siteMeta.url}/images/social/open-graph.png`
  head.twitterCard ??= 'summary'
  head.twitterImage ??= `${siteMeta.url}/images/social/twitter.png`
  const route = useRoute()
  const currentAddress = `${siteMeta.url}${route.path}`
  useSeoMeta({
    title: head.title,
    description: head.description,
    ogTitle: head.title,
    ogDescription: head.description,
    ogType: 'website',
    ogSiteName: siteMeta.name,
    ogUrl: currentAddress,
    ogImage: head.openGraphImage,
    ogLocale: 'fr',
    twitterCard: head.twitterCard,
    twitterTitle: head.title,
    twitterDescription: head.description,
    twitterSite: '@Skyost',
    twitterCreator: '@Skyost',
    twitterImage: head.twitterImage,
  })
  useHead({
    meta: [
      {
        name: 'twitter:url',
        content: currentAddress,
      },
    ],
    link: [
      {
        rel: 'canonical',
        href: currentAddress,
      },
    ],
  })
}
