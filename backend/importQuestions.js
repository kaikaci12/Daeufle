const allQuestions = require("./questions.json");
const serviceAccount = require("./serviceAccountKey.json");
const express = require("express");
const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const app = express();
const db = admin.firestore();

async function uploadQuestions() {
  console.log("Starting To upload questions....");
  for (const question of allQuestions) {
    try {
      const newDocRef = db.collection("questions").doc();
      const generatedId = newDocRef.id;
      await newDocRef.set(question);
      console.log(`Successfully added question with ID: ${generatedId}`);
    } catch (error) {
      console.error("Error uploading a question: ", error);
    }
  }
}
uploadQuestions();
