const allQuestions = require("./questions.json");
const allCourses = require("./courses.json");
const serviceAccount = require("./serviceAccountKey.json");

const admin = require("firebase-admin");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

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
async function uploadCourses() {
  console.log("Starting To upload courses....");
  for (const course of allCourses) {
    try {
      const newDocRef = db.collection("courses").doc();
      const generatedId = newDocRef.id;
      await newDocRef.set(course);
      console.log(`Successfully added course with ID: ${generatedId}`);
    } catch (error) {
      console.error("Error uploading a course: ", error);
    }
  }
}
uploadCourses();
