/**
 * Import function triggers from their respective submodules :
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from 'firebase-functions/v2/https'
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
