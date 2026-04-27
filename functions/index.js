const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");

exports.generateDietPlan = onRequest(async (req, res) => {
    try {
        const { age, weight, goal, dietType } = req.body;

        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: "deepseek/deepseek-chat",
                messages: [
                    {
                        role: "user",
                        content: `
Generate a personalized Indian diet plan:
Age: ${age}
Weight: ${weight}
Goal: ${goal}
Diet Type: ${dietType}

Include:
- Breakfast
- Lunch
- Dinner
- Snacks
- Calories
- Protein
`
                    }
                ]
            },
            {
                headers: {
                    Authorization: "Bearer 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",
                    "Content-Type": "application/json"
                }
            }
        );

        res.json(response.data);
    } catch (error) {
        console.error(error.response?.data || error.message);
        res.status(500).send("Error generating diet plan");
    }
});