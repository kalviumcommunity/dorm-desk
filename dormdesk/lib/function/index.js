const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * ✅ Callable Function
 * Triggered directly from Flutter
 */
exports.sayHello = functions.https.onCall((data, context) => {
  const name = data.name || "DormDesk User";

  console.log("Function triggered with name:", name);

  return {
    message: `Hello, ${name}! Welcome to DormDesk 🚀`
  };
});


/**
 * ✅ Firestore Event-Based Trigger
 * Runs automatically when new issue is created
 */
exports.onNewIssueCreated = functions.firestore
  .document("issues/{issueId}")
  .onCreate((snap, context) => {

    const issueData = snap.data();

    console.log("New Issue Created:", issueData);

    return snap.ref.update({
      processed: true,
      serverTimestamp: admin.firestore.FieldValue.serverTimestamp()
    });
  });