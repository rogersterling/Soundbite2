import Foundation

class AssemblyAIService {
    private let apiKey: String
    private let baseURL = "https://api.assemblyai.com/v2"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func transcribeAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        // First, upload the audio file
        uploadAudio(fileURL: fileURL) { result in
            switch result {
            case .success(let audioURL):
                // Then, start transcription
                self.startTranscription(audioURL: audioURL, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func uploadAudio(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        let uploadURL = URL(string: "\(baseURL)/upload")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let uploadedFileURL = json["upload_url"] as? String else {
                completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            completion(.success(uploadedFileURL))
        }
        task.resume()
    }
    
    private func startTranscription(audioURL: String, completion: @escaping (Result<String, Error>) -> Void) {
        let transcriptionURL = URL(string: "\(baseURL)/transcript")!
        var request = URLRequest(url: transcriptionURL)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let body: [String: Any] = ["audio_url": audioURL]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["id"] as? String else {
                completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            self.checkTranscriptionStatus(id: id, completion: completion)
        }
        task.resume()
    }
    
    private func checkTranscriptionStatus(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        let statusURL = URL(string: "\(baseURL)/transcript/\(id)")!
        var request = URLRequest(url: statusURL)
        request.setValue(apiKey, forHTTPHeaderField: "authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            if let status = json["status"] as? String {
                if status == "completed" {
                    if let text = json["text"] as? String {
                        completion(.success(text))
                    } else {
                        completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Transcription completed but no text found"])))
                    }
                } else if status == "error" {
                    completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Transcription failed"])))
                } else {
                    // If it's still processing, check again after a delay
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        self.checkTranscriptionStatus(id: id, completion: completion)
                    }
                }
            } else {
                completion(.failure(NSError(domain: "AssemblyAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid status in response"])))
            }
        }
        task.resume()
    }
}
