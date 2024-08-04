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
          "name": "Name of the food item",
          "category": "Meal category (e.g., breakfast, lunch, dinner, snack)",
          "time": "Time of consumption",
          "ingredients": ["List", "of", "ingredients"],
          "carb_level": "Description of carb content",
          "carbs_g": null,
          "protein_level": "Description of protein content",
          "protein_g": null,
          "fat_level": "Description of fat content",
          "fat_g": null,
          "sugar_content": "Description of sugar content",
          "sugar_g": null,
          "fiber_content": "Description of fiber content",
          "fiber_g": null,
          "feeling": "User's feeling or state related to this meal",
          "notes": "Any additional relevant information"
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
    
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
    request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
    
    let body: [String: Any] = [
        "model": "claude-3-5-sonnet-20240620",
        "max_tokens": 1000,
        "messages": [
            ["role": "user", "content": prompt]
        ]
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ClaudeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Claude API Response: \(rawResponse)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let firstContent = content.first,
                   let text = firstContent["text"] as? String,
                   let jsonData = text.data(using: .utf8) {
                    
                    let decoder = JSONDecoder()
                    let mealEntry = try decoder.decode(MealEntry.self, from: jsonData)
                    completion(.success(mealEntry))
                } else {
                    throw NSError(domain: "ClaudeService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct MealEntry: Codable {
    let whatConsumed: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case whatConsumed = "what_consumed"
    }
}