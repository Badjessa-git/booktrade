'use strict'
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp(functions.config().firebase);

const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;
const mailTransport = nodemailer.createTransport({
      service: 'gmail',
      auth: {
            user: gmailEmail,
            pass: gmailPassword,
      }
});
const APP_NAME = 'BookTrade';

exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
      if (user.email.includes('lehigh.edu')) {
         const email = user.email;
         const displayName = user.displayName;
         
         return sendWelcomeEmail(email, displayName);
      }
});

function sendWelcomeEmail(email, displayName) {
      const mailOptions = {
            from: '${APP_NAME}<noreply@firebase.com>',
            to: email,
      };

      mailOptions.subject = 'Welcome to ${APP_NAME}',
      mailOptions.text = 'Hey ${displayName || ""}! Welcome to ${APP_NAME}. \n' + 
                        'Thank you for joining our service. \n'
                        +'We hope you enjoy our service and do not hesitate to contact us if you encounter any problems'
                        +'\nBest'
                        +'\nThe BookTrade Team.';
      return mailTransport.sendMail(mailOptions).then(() => {
            return console.log('Welcome email sent to:', email);
      })
}

exports.sendPushMessage = functions.firestore
      .document('chatrooms/{chatroomID}/messages/{message}')
      .onCreate((docSnapshot, context) => {
            const message = docSnapshot.data();
            const userUID = message['receiverUID'];
            const senderName = message['name'];
            //Retrieve FCM token to send the message
            return admin.firestore().doc('users/' + userUID).get().then(userDoc => {
                  const notify = userDoc.get('notify');
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
                  
                  if (notify == true) {
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
                                                      stillResterederedTokens.splice(failedIndex, index)
                                                }
                                          }
                                    }
                              })
      
                              return admin.firestore().doc("users/"+userUID).update({
                                    deviceToken : stillResterederedTokens
                              });
                        })
                  }
            })

      });

exports.updateDatabse = functions.firestore
      .document('book_lehigh/{bookId}')
      .onDelete(context => {
            //for each adding to wishlist, add the user id to the bookid in the wishlist creation
            const bookId = context.params.bookId;
            //Retrieve the list of users who had the book in the wishlist
            return admin.firestore().doc('wishlist/'+ bookId).get().then(list => {
                  const userList = list['users'];
                  userList.forEach(((userId, index) => {
                        return admin.firestore().doc('users/'+userId+'/wishlist/'+bookId).delete();
                  }));
            })
      });

