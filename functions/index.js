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

exports.sendsWelcomeEmail = functions.firestore
      .document('users/{userID}')
      .onCreate((userSnapshot, context) => {
            const user = userSnapshot.data();
                     const email = user['email'];
                     const displayName = user['displayName'];
                     
                     return sendWelcomeEmail(email, displayName);
                  
      });

function sendWelcomeEmail(email, displayName) {
      const mailOptions = {
            from: APP_NAME+'<noreply@firebase.com>',
            to: email,
      };

      mailOptions.subject = 'Welcome to ' + APP_NAME,
      mailOptions.text = 'Hey '+ displayName +'! \n Welcome to ' + APP_NAME + '.\n' + 
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

exports.updateDatabase = functions.firestore
      .document('books/{bookId}')
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

exports.reportBook = functions.firestore
      .document('reports_book/{reports_bookId}')
      .onCreate(docSnapshot => {
            const docInfo = docSnapshot.data();
            const userEmail = docInfo['submitterEmail'];
            const displayName = docInfo['submitterDisplayName'];
            const bookId = docInfo['bookId'];
            return admin.firestore().doc('books/'+bookId).get().then(bookDoc => {
                  const bookDocs = bookDoc.data();
                  const ISBN = bookDocs['isbn'];
                  const title = bookDocs['title'];
                  
                  return sendBookReport(userEmail, displayName, ISBN, title)
                  
            });
      });

      function sendBookReport(email, displayName, ISBN, title) {
            const mailOptions = {
                  from: APP_NAME+ "<noreply@firebase.com>",
                  to: email,
                  bcc: "romeobazil@gmail.com"
            }

            mailOptions.subject = "Your report has been successfully submitted",
            mailOptions.text = "Hello "+ displayName
                              + '\n\n This email is to inform you that the report that you submitted about the book '
                              + '\n ISBN: ' + ISBN 
                              + '\n Title: ' + title
                              + '\n We take your input very seriously, we will review your submission and act accordingly'
                              + '\n\n Thank you,'                              
                              + '\n The BookTrade Team.';
            
            return mailTransport.sendMail(mailOptions).then(() => {
                  return console.log('Report has been sent to: ', email);
            })
      }

exports.reportUser = functions.firestore
      .document('reports_user/{reports_userId}')
      .onCreate(docSnapshot => {
            const docInfo = docSnapshot.data();
            const senderEmail = docInfo['submitterEmail'];
            const senderDisplayname = docInfo['submitterDisplay'];
            const uid = docInfo['userId'];
            return admin.firestore().doc('users/' + uid).get().then(userDoc => {
                  const email = userDoc['email'];
                  const displayName = userDoc['displayName'];

                  return sendUserReport(email, displayName).then(() => {
                        return sendReporterNotification(senderEmail, senderDisplayname)    
                  });
            });
      });

      function sendUserReport(email, displayName) {
            const mailOptions = {
                  from: APP_NAME+ "<noreply@firebase.com>",
                  to: email,
                  bcc: "romeobazil@gmail.com"
            }

            mailOptions.subject = "You have been reported of misconduct",
            mailOptions.text = "Hello "+ displayName
                              + '\n\n This email is to inform you that you have been reported by other User for misconduct. '
                              + '\n We will review the content of the report and if you are found to be in violation of our End User License Agreement, ' 
                              + 'we will be considering temporary submission of your account or termination'
                              + '\n\n Thank you,'
                              + '\n The BookTrade Team.';
            
            return mailTransport.sendMail(mailOptions).then(() => {
                  return console.log('Report has been sent to: ', email);
            });            
      }

      function sendReporterNotification(email, displayName) {
            const mailOptions = {
                  from: APP_NAME+ "<noreply@firebase.com>",
                  to: email,
                  bcc: "romeobazil@gmail.com"
            }

            mailOptions.subject = "Your report has been submit",
            mailOptions.text = "Hello "+ displayName
                              + '\n\n This email is to inform you that your report has been submitted'
                              + '\n We will review the content of the report and take actions based on the review.'
                              + '\n We value your input and thank you for using our applications.'
                              + '\n\n Thank you,'
                              + '\n The BookTrade Team.';
            
            return mailTransport.sendMail(mailOptions).then(() => {
                  return console.log('Report has been sent to: ', email);
            });            
      }
      