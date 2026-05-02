//
//  OpenAIService.swift
//  Funcation
//
//  Handles OpenAI API communication for the Research tab.
//

import Foundation

final class OpenAIService {
    
    static let shared = OpenAIService()
    private init() {}
    
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String,
              !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("OpenAI API key is missing.")
            return ""
        }
        return key
    }
    
    struct TravelInfo: Codable {
        let title: String
        let price: String
        let location: String
        let summary: String
    }
    
    func extractTravelInfo(
        from urlString: String,
        completion: @escaping (Result<TravelInfo, Error>) -> Void
    ) {
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: trimmedURL),
              url.scheme == "http" || url.scheme == "https" else {
            completion(.failure(OpenAIServiceError.invalidURL))
            return
        }
        
        guard !apiKey.isEmpty else {
            completion(.failure(OpenAIServiceError.missingAPIKey))
            return
        }
        
        guard let endpoint = URL(string: "https://api.openai.com/v1/responses") else {
            completion(.failure(OpenAIServiceError.invalidEndpoint))
            return
        }
        
        let prompt = """
        Extract useful travel planning information from this URL:
        \(url.absoluteString)

        Return ONLY valid JSON with exactly these keys:
        {
          "title": "",
          "price": "",
          "location": "",
          "summary": ""
        }

        If information is unavailable, use an empty string.
        Do not include markdown.
        Do not include explanations.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "input": prompt,
            "temperature": 0.2
        ]
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("OpenAI status code:", httpResponse.statusCode)
            }
            
            guard let data = data else {
                completion(.failure(OpenAIServiceError.noDataReturned))
                return
            }
            
            do {
                let responseText = try Self.extractTextFromResponseData(data)
                
                guard let jsonData = responseText.data(using: .utf8) else {
                    completion(.failure(OpenAIServiceError.invalidJSON))
                    return
                }
                
                let travelInfo = try JSONDecoder().decode(TravelInfo.self, from: jsonData)
                completion(.success(travelInfo))
                
            } catch {
                print("OpenAI raw response:")
                print(String(data: data, encoding: .utf8) ?? "Could not print response.")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private static func extractTextFromResponseData(_ data: Data) throws -> String {
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        if let outputText = jsonObject?["output_text"] as? String, !outputText.isEmpty {
            return outputText
        }
        
        guard let output = jsonObject?["output"] as? [[String: Any]] else {
            throw OpenAIServiceError.noOutputText
        }
        
        for item in output {
            guard let contentArray = item["content"] as? [[String: Any]] else {
                continue
            }
            
            for content in contentArray {
                if let text = content["text"] as? String, !text.isEmpty {
                    return text
                }
            }
        }
        
        throw OpenAIServiceError.noOutputText
    }
}

enum OpenAIServiceError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case invalidEndpoint
    case noDataReturned
    case noOutputText
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Please enter a valid URL."
        case .missingAPIKey:
            return "OpenAI API key is missing."
        case .invalidEndpoint:
            return "OpenAI endpoint is invalid."
        case .noDataReturned:
            return "No data was returned from OpenAI."
        case .noOutputText:
            return "OpenAI did not return readable output."
        case .invalidJSON:
            return "OpenAI returned invalid JSON."
        }
    }
}
