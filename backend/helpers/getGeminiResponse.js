const { GoogleGenerativeAI } = require("@google/generative-ai");
const geminiApiKey = process.env.GEMINI_API_KEY;
if (!geminiApiKey) {
  console.error("CRITICAL ERROR: GEMINI_API_KEY environment variable not set.");
}
const genAI = new GoogleGenerativeAI(geminiApiKey);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

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
module.exports = { getGeminiResponse };
