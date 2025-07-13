require("dotenv").config();

const cors = require("cors"); // Import cors package

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

if (!serviceAccountPath) {
  console.error(
    "CRITICAL ERROR: FIREBASE_SERVICE_ACCOUNT_PATH environment variable not set."
  );
  process.exit(1);
}
let serviceAccount;
try {
  serviceAccount = require(serviceAccountPath);
} catch (error) {
  console.error(
    `CRITICAL ERROR: Could not load service account key from ${serviceAccountPath}. Please check the path and file existence.`,
    error
  );
  process.exit(1);
}

const express = require("express");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();
app.use(cors()); // Use the cors middleware
const db = admin.firestore();

const geminiApiKey = process.env.GEMINI_API_KEY;
if (!geminiApiKey) {
  console.error("CRITICAL ERROR: GEMINI_API_KEY environment variable not set.");
}
const genAI = new GoogleGenerativeAI(geminiApiKey);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

app.use(express.json());

// Define getGeminiResponse function BEFORE it's called
const getGeminiResponse = async (prompt) => {
  try {
    const result = await model.generateContent({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: {
          type: "OBJECT",
          properties: {
            careerRecommendation: { type: "STRING" }, // Changed to 'careerRecommendation' to match prompt
            professionIds: {
              type: "ARRAY",
              items: { type: "STRING" },
            },
          },
          propertyOrdering: ["careerRecommendation", "professionIds"],
        },
      },
    });
    return result.response;
  } catch (error) {
    console.error(
      "Error in getGeminiResponse (Gemini API call failed):",
      error
    );
    throw error; // Re-throw the error for higher-level handling
  }
};

app.post("/api/quiz/analyze", async (req, res) => {
  console.log("started analizing");

  let prompt =
    "Analyze the following quiz answers to suggest a career path and provide a brief careerRecommendation (50 words max). Focus on the user's preferences and strengths. Considering the numerical value of their choices and the associated career impact scores for each question. Also, provide a list of relevant profession IDs (e.g., 'software_engineer', 'data_scientist', 'graphic_designer', 'teacher', 'doctor', 'artist').\n\nAnswers:\n";
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
    // Simulate querying courses based on professionIds
    if (
      parsedGeminiResponse.professionIds &&
      Array.isArray(parsedGeminiResponse.professionIds)
    ) {
      for (const profId of parsedGeminiResponse.professionIds) {
        suitableCoursesData.push({
          id: `course_${profId}_1`,
          name: `Intro to ${profId} Course`,
          description: `Learn the basics of ${profId} in this foundational course.`,
        });
        suitableCoursesData.push({
          id: `course_${profId}_2`,
          name: `Advanced ${profId} Techniques`,
          description: `Deep dive into advanced ${profId} skills.`,
        });
      }
    }

    console.log(parsedGeminiResponse);
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
