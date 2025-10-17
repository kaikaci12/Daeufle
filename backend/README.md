# 🚀 Daeufle-API: AI Career Analysis Backend

The Daeufle-API is an Express.js backend service that provides AI-driven career and course recommendations. It uses **Google Gemini** for intelligent analysis of user quiz answers and leverages **Google Firestore** for data persistence and retrieval of quiz metadata and course information.

The primary goal is to offer a **reliable, programmatic pipeline** for frontend and mobile clients to receive structured career insights and matching course suggestions.

## ✨ Main Feature

The core of the API is the **AI Career Analysis endpoint**, which transforms a user's quiz answers into actionable recommendations:

1.  **Enrichment:** Adds contextual metadata from Firestore to the user's answers.
2.  **AI Analysis:** Sends a structured prompt to `gemini-2.0-flash` to get a structured JSON output.
3.  **Persistence:** Stores the result under the authenticated user's profile.
4.  **Matching:** Filters the available courses to find those that match the AI's recommended professions.

### Output Structure

| Field | Type | Description |
| :--- | :--- | :--- |
| `careerRecommendation` | `string` | A concise, human-readable recommendation from the AI. |
| `professionIds` | `string[]` | An array of canonical profession identifiers (e.g., `software_engineer`). |
| `suitableCourses` | `object[]` | A list of course objects from Firestore that match the recommended `professionIds`. |

## 🛠️ Key Technologies

* **Node.js** & **Express.js:** Core HTTP API framework.
* **Firebase Admin SDK:** User authentication (`verifyFirebaseToken`) and Firestore database access.
* **@google/generative-ai:** Access to the Google Gemini model.
* **Firestore:** Data storage for questions, courses, and user quiz results.

---

## 🔒 API Authentication

All requests to the analysis endpoint **must** be authenticated. The backend uses the **Firebase Admin SDK** to verify a user's ID token.

### Header Format

| Header | Example |
| :--- | :--- |
| `Authorization` | `Bearer <FIREBASE_ID_TOKEN>` |
| `Content-Type` | `application/json` |

---

## 🎯 API Endpoint: `/api/quiz/analyze`

### `POST /api/quiz/analyze`

**Description:** Accepts a user's quiz answers, processes them through the AI pipeline, and returns the recommendation and matching courses.

#### Request Body (JSON)

An array of answers mapping a `questionId` to a `selectedOptionId`.

```json
[
  { "questionId": "q1", "selectedOptionId": "opt_a" },
  { "questionId": "q2", "selectedOptionId": "opt_c" }
]
Response (HTTP 200 OK)
A structured JSON object containing the AI's output and the filtered courses.

JSON

{
  "careerRecommendation": "Based on your answers, you show strong analytical and problem-solving skills — consider software engineering with a focus on backend development.",
  "professionIds": ["software_engineer", "backend_developer"],
  "suitableCourses": [
    {
      "id": "course123",
      "title": "Node.js: The Complete Guide",
      "provider": "Udemy",
      "...": "other course fields"
    }
  ]
}

  { "questionId": "q1", "selectedOptionId": "opt_a" },
  { "questionId": "q2", "selectedOptionId": "opt_c" }
]
