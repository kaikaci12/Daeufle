require("dotenv").config();

const cors = require("cors"); // Import cors package

const serviceAccountCredentials =
  process.env.FIREBASE_SERVICE_ACCOUNT_CREDENTIALS;

if (!serviceAccountCredentials) {
  console.error(
    "CRITICAL ERROR: FIREBASE_SERVICE_ACCOUNT_CREDENTIALS environment variable not set."
  );
  process.exit(1);
}

let serviceAccount;
try {
  // Parse the JSON string from the environment variable
  serviceAccount = JSON.parse(serviceAccountCredentials);
} catch (error) {
  console.error(
    `CRITICAL ERROR: Could not parse service account credentials from environment variable. Please check its format.`,
    error
  );
  process.exit(1);
}

const express = require("express");
const admin = require("firebase-admin");

const { getGeminiResponse } = require("./helpers/getGeminiResponse");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const verifyFirebaseToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res
      .status(401)
      .json({ message: "Unauthorized: No token provided or invalid format." });
  }

  const idToken = authHeader.split("Bearer ")[1];

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken; // Attach the decoded token to the request
    next();
  } catch (error) {
    console.error("Error verifying Firebase ID token:", error);
    return res
      .status(401)
      .json({ message: "Unauthorized: Invalid or expired token." });
  }
};
const app = express();
app.use(cors()); // Use the cors middleware
const db = admin.firestore();

app.use(express.json());

app.post("/api/quiz/analyze", verifyFirebaseToken, async (req, res) => {
  console.log("started analizing");

  let prompt =
    "Analyze the following quiz answers to suggest a career path and provide a brief careerRecommendation (50 words max). Focus on the user's preferences and strengths. Considering the numerical value of their choices and the associated career impact scores for each question. Also, provide a list of relevant profession IDs (e.g., 'software_engineer', 'data_scientist', 'graphic_designer', 'doctor', 'artist','digital_marketer', 'marketing_manager', 'content_creator' 'social_media_manager','psychologist', 'counselor', 'social_worker', 'hr_specialist').\n\nAnswers:\n";
  const selectedAnswers = req.body;
  console.log("selectedAnswers: ", selectedAnswers);

  if (
    !selectedAnswers ||
    !Array.isArray(selectedAnswers) ||
    selectedAnswers.length === 0
  ) {
    console.warn(
      "Invalid or empty selectedAnswers provided in request body:",
      selectedAnswers
    );
    return res.status(400).json({
      message: "Invalid or empty selectedAnswers provided.",
    });
  }

  // Loop to build the prompt - this must complete BEFORE calling Gemini
  for (const answer of selectedAnswers) {
    const questionId = answer.questionId;
    const selectedOptionId = answer.selectedOptionId;
    if (!questionId || !selectedOptionId) {
      console.warn(
        "Skipping invalid answer entry (missing questionId or selectedOptionId):",
        answer
      );
      continue;
    }
    try {
      const questionDoc = await db
        .collection("questions")
        .doc(questionId)
        .get();
      if (questionDoc.exists) {
        const questionData = questionDoc.data();
        const questionText = questionData.questionText;
        const options = questionData.options;
        const selectedOption = options.find(
          (opt) => opt.id == selectedOptionId
        );
        if (selectedOption) {
          prompt += `- Question: "${questionText}"\n  Selected: "${selectedOption.text}" (Value: ${selectedOption.value})\n`;
          if (questionData.careerImpacts) {
            prompt += `- Career impact values for this question: ${JSON.stringify(
              questionData.careerImpacts
            )}\n`;
          }
        } else {
          prompt += `- Question: "${questionText}"\n  Selected option ID "${selectedOptionId}" not found within its options.\n`;
        }
      } else {
        prompt += `- Question ID "${questionId}" not found in Firestore.\n`;
      }
    } catch (error) {
      console.error(
        `Error fetching details for question ${questionId}:`,
        error
      );
      prompt += `- Error fetching details for question ${questionId}: ${error.message}.\n`;
    }
  } // End of for loop

  console.log("Final prompt: ", prompt);

  // Gemini API call and response handling - this block must be OUTSIDE the for loop
  try {
    const result = await getGeminiResponse(prompt); // Pass prompt to the function
    const geminiResponse = result; // getGeminiResponse now returns the response object directly
    const responseText = geminiResponse.text();

    let parsedGeminiResponse;
    try {
      parsedGeminiResponse = JSON.parse(responseText);
    } catch (parseError) {
      // Corrected variable name from 'error' to 'parseError'
      console.error("Error parsing Gemini's JSON response:", parseError);
      console.error("Raw Gemini response text:", responseText);
      return res.status(500).json({
        message: "AI analysis returned invalid JSON.",
        error: parseError.message,
        rawResponse: responseText,
      });
    }

    // Initialize suitableCoursesData before use
    let suitableCoursesData = [];
    try {
      const coursesRef = await db.collection("courses").get();
      const professionIds = parsedGeminiResponse.professionIds || [];

      for (const doc of coursesRef.docs) {
        const courseData = doc.data();
        const courseProfessionIds = courseData.associatedProfessionIds || [];

        const isSuitable = professionIds.some((profId) =>
          courseProfessionIds.includes(profId)
        );
        if (isSuitable) {
          suitableCoursesData.push({ id: doc.id, ...courseData });
        }
      }
    } catch (error) {
      console.error("Failed processing courses: ", error);
      return res.json({
        message: "Failed to process course suggestions",
        error: error.message,
      });
    }

    const userId = req.user.uid;
    const quizResultsRef = db
      .collection("users")
      .doc(userId)
      .collection("quizResults")
      .doc("latest");
    await quizResultsRef.set({
      careerRecommendation: parsedGeminiResponse.careerRecommendation, // Changed back to careerRecommendation
      professionIds: parsedGeminiResponse.professionIds,
      suitableCourses: suitableCoursesData,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(parsedGeminiResponse);
    console.log("Saved User quizResults ✅");
    res.json({
      careerRecommendation: parsedGeminiResponse.careerRecommendation, // Changed from careerRecommendation to careerRecommendation
      professionIds: parsedGeminiResponse.professionIds, // Added professionIds to response
      suitableCourses: suitableCoursesData,
    });
  } catch (error) {
    console.error("Error during AI analysis or Gemini API call:", error);
    res.status(500).json({
      message: "Failed to analyze quiz results with AI.",
      error: error.message,
    });
  }
});

app.listen(5000, () => {
  console.log("app is listening on port", 5000);
});
