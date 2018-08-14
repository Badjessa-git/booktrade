const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

exports.sendPushMessage = functions.firestore
      .document('chatrooms/{chatroomID}/messages/{message}')
      .onCreate((docSnapshot, context) => {
            const message = docSnapshot.data();
            const userUID = message['receiverUID'];
            const senderName = message['name'];
            //Retrieve FCM token to send the message
            return admin.firestore().doc('users/' + userUID).get().then(userDoc => {
                  const FCMtoken = userDoc.get('deviceToken');
                  const NotificationBody = (message['imageUrl']) ?
                        "You have received a new Image message"
                        : message['message']

                  const payload = {
                        notification: {
                              title: senderName,
                              body: NotificationBody,
                        },
                        data: {
                              chatroomID: context.params.chatroomID,
                              UID: userUID,
                        }
                  }

                  return admin.messaging().sendToDevice(FCMtoken, payload).then(response =>{
                        const stillResterederedTokens = FCMtoken

                        response.results.forEach((result, index) => {
                              const error = result.error
                              if (error) {
                                    const failedRegistrationToken = FCMtoken;
                                    console.error("Error sending Message to decice", failedRegistrationToken, error)
                                    if (error.code === 'messaging/invalid-registration-token' 
                                    || error.code === 'messaging/registration-token-not-registered') {
                                          const failedIndex = stillResterederedTokens.indexOf(failedRegistrationToken)
                                          if (failedIndex > -1) {
                                                stillResterederedTokens.splice(failedIndex, 1)
                                          }
                                    }
                              }
                        })

                        return admin.firestore().doc("users/"+userUID).update({
                              deviceToken : stillResterederedTokens
                        });
                  })
            })

      });
