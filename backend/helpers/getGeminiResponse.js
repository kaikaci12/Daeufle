module.exports = async (prompt, model) => {
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
