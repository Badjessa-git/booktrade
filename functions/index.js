const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendMessage = functions.firestore
      .document('/messages/{chatroom}/')
