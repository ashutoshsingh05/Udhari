const functions = require("firebase-functions");

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

var admin = require("firebase-admin");
// var serviceAccount = require("/home/ashutosh/Projects/Flutter Apps/piety_store_app/functions/serviceAccountKey.json");
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
//   databaseURL: "https://laundrycustomer-cb9f2.firebaseio.com",
// });

admin.initializeApp(functions.config().firebase);

// This functions sends a notification for whatever purpose we might need
// Data has to be the payload with fcmToken of whom to send this message
// This function is not actually required but it's here just for future purposes
exports.sendNotification = functions.https.onCall(async (data, context) => {
  const payload = data.payload;
  const fcm = data.fcm;
  const response = await admin.messaging().sendToDevice(fcm, payload);
  if (response.results.error) {
    console.error("Failure sending notification to ", fcmStore, error);
  }
});

// Fired whenever a new udhari is created. This functions
// sends two notifications, one to firstParty and the other
// to second party
exports.udhariCreated = functions.firestore
  .document("udhari/{documentId}")
  .onCreate(async (snapshot, context) => {
    var fcmFirstParty = snapshot.data().firstPartyFcmToken;
    var fcmSecondParty = snapshot.data().secondPartyFcmToken;
    var amount = snapshot.data().amount;
    var secondPartyName;
    var secondPartyNumber;

    console.log(
      "fcmFirstParty: ",
      fcmFirstParty,
      " fcmSecondParty: ",
      fcmSecondParty
    );

    if (snapshot.data().firstParty === snapshot.data().lender) {
      secondPartyName = snapshot.data().lenderName;
      secondPartyNumber = snapshot.data().lender;
    } else if (snapshot.data().firstParty === snapshot.data().borrower) {
      secondPartyName = snapshot.data().borrowerName;
      secondPartyNumber = snapshot.data().borrower;
    }

    console.log(
      "secondPartyName: ",
      secondPartyName,
      " secondPartyNumber: ",
      secondPartyNumber,
      " amount: ",
      amount
    );

    const payloadFirstParty = {
      notification: {
        title: "Udhari Added",
        body: "New udhari was successfully added",
      },
    };
    const payloadSecondParty = {
      notification: {
        title: "New Udhari",
        body:
          "New Udhari ₹"+amount+" from " +
          secondPartyName +
          " (" +
          secondPartyNumber +
          ")",
      },
    };

    const responseFirstParty = await admin
      .messaging()
      .sendToDevice(fcmFirstParty, payloadFirstParty);
    const responseSecondParty = await admin
      .messaging()
      .sendToDevice(fcmSecondParty, payloadSecondParty);

    if (responseFirstParty.results.error) {
      console.error("Failure sending notification to ", fcmFirstParty, error);
    }
    if (responseSecondParty.results.error) {
      console.error("Failure sending notification to ", fcmSecondParty, error);
    }
  });
