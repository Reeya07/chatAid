const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Simple test chatbot function
exports.chatReply = functions.https.onCall(async (data, context) => {
  // Ensure user is logged in
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be logged in"
    );
  }

  const message = data.message || "";

  return {
    reply: "Chatbot backend is working ✅",
  };
});
