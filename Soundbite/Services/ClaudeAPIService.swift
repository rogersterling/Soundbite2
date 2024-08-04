import Foundation

class ClaudeService {
    private let apiKey: String
    private let apiUrl = URL(string: "https://api.anthropic.com/v1/messages")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func processTranscription(_ transcription: String, completion: @escaping (Result<MealEntry, Error>) -> Void) {
        let prompt = """
        Below is a transcription of the user's food consumption and health-related experiences for today or a recent day. Please analyze the transcript and create a JSON output that describes it. Only include properties that are explicitly mentioned or can be clearly inferred from the transcript. Leave properties blank if they are not mentioned or cannot be confidently inferred.

        Here's the JSON structure to use:

        {
          "what_consumed": [
            {
              "date": "",
              "time": "",
              "name": "",
              "category": "",
              "ingredients": [],
              "carb_level": "",
              "carbs_g": null,
              "protein_level": "",
              "protein_g": null,
              "fat_level": "",
              "fat_g": null,
              "sugar_content": "",
              "sugar_g": null,
              "fiber_content": "",
              "fiber_g": null,
              "feeling": "",
              "notes": ""
            }
          ]
        }

        Notes:
        - The "what_consumed" array may contain multiple entries if more than one meal is described.
        - Use null for numeric fields (e.g., carbs_g) when no specific value is provided.
        - Only include properties that have a value; omit empty strings or null values.
        - Infer the "category" (e.g., breakfast, lunch, dinner, snack) from context if possible.
        - The "feeling" field should capture the user's emotional or physical state related to the meal.
        - The "notes" field should include any additional relevant information about the meal or experience.

        Please process the following transcript:

        \(transcription)
        """
        
        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20240620",
            "max_tokens": 1000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "x-api-key")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ClaudeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = jsonResult["content"] as? String {
                    // Parse the content to extract the JSON part
                    if let jsonStart = content.range(of: "{"),
                       let jsonEnd = content.range(of: "}", options: .backwards) {
                        let jsonString = content[jsonStart.lowerBound...jsonEnd.upperBound]
                        let jsonData = Data(jsonString.utf8)
                        let mealEntry = try JSONDecoder().decode(MealEntry.self, from: jsonData)
                        completion(.success(mealEntry))
                    } else {
                        completion(.failure(NSError(domain: "ClaudeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to extract JSON from Claude's response"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "ClaudeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct MealEntry: Codable {
    var whatConsumed: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case whatConsumed = "what_consumed"
    }
}
