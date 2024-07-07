/**
 * Import function triggers from their respective submodules :
 *
 * import { onCall } from 'firebase-functions/v2/https'
 * import { onDocumentWritten } from 'firebase-functions/v2/firestore'
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as admin from 'firebase-admin'
admin.initializeApp()
import { FieldValue } from 'firebase-admin/firestore'

import { onRequest } from 'firebase-functions/v2/https'
import { onDocumentCreated, onDocumentDeleted } from 'firebase-functions/v2/firestore'

// import * as logger from 'firebase-functions/logger'

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

export const appleLogin = onRequest(
  {
    region: 'europe-west1',
  },
  (request, response) => {
    const data = request.body
    if (!data || !data['code'] || !data['id_token'] || !data['state']) {
      response.redirect('/')
      return
    }
    response.redirect(`http://localhost:5000/apple/?code=${data['code']}&id_token=${data['id_token']}&state=${data['state']}`)
  }
)

export const incrementCounter = onDocumentCreated(
  {
    region: 'europe-west1',
    document: '/{userId}/userData/totps/{documentId}',
  }, async (event) => {
    await _incrementCounterBy(event.params.userId, 1)
  }
)

export const decrementCounter = onDocumentDeleted(
  {
    region: 'europe-west1',
    document: '/{userId}/userData/totps/{documentId}',
  }, async (event) => {
    await _incrementCounterBy(event.params.userId, -1)
  }
)

const _incrementCounterBy = async (userId: string, by: number) => {
  const database = admin.firestore()
  const userData = database.collection(userId).doc('userData')
  await userData.update({
    totpCount: FieldValue.increment(by),
  })
}
