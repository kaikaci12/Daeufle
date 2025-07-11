const allQuestions = require("./questions.json");
const serviceAccount = require("./serviceAccountKey.json");
const express = require("express");
const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const app = express();
const db = admin.firestore();
port = 3000;
app.get("/", async (req, res) => {
  const snapshot = await db.collection("questions").get();
  const question1 = snapshot.docs[0];

  res.json({
    content: question1.data().questionText,
    date: Date.now().toString(),
  });
});

app.listen(port, () => {
  console.log("app is listening on port", port);
});
