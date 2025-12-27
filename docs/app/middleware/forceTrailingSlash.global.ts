export default defineNuxtRouteMiddleware((to, from) => {
  if (import.meta.client && to.path.slice(-1) !== '/' && from.path.slice(-1) === '/' && to.path === from.path.slice(0, -1)) {
    return abortNavigation()
  }
})
