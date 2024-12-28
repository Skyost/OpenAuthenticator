export default defineNuxtRouteMiddleware((to) => {
  if (!to.path.endsWith('/')) {
    const nextRoute = {
      path: to.path + '/',
      query: to.query,
      hash: to.hash,
    }
    return navigateTo(nextRoute, { redirectCode: 301 })
  }
})
