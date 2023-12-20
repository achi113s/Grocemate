//
//  OpenAIManager.swift
//  Grocemate
//
//  Created by Giorgio Latour on 12/18/23.
//

import Foundation

protocol OpenAIManageable {
    var completionsEndpoint: String { get set }
    var apiKey: String { get set }
    var organization: String { get set }

    func postMessageToCompletionsEndpoint(requestObject: CompletionRequest) -> OpenAIResponse
}

/// Manage the connection with the OpenAI API for Chat Completion.
class OpenAIManager: NSObject, ObservableObject {
    private let completionsEndpoint = "https://api.openai.com/v1/chat/completions"

    private var apiKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    }

    private var organization: String {
        Bundle.main.infoDictionary?["OPENAI_ORGANIZATION"] as? String ?? ""
    }

//    public func postMessageToCompletionsEndpoint(
//        requestObject: CompletionRequest
//    ) async throws -> OpenAIResponse {
//        guard let url = URL(string: completionsEndpoint) else { throw URLError(.badURL) }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

//        let message = Message(role: role, content: content)
//        let requestObject = CompletionRequest(model: model, maxTokens: 1000, messages: [message], temperature: temperature, stream: false)
//        let requestData = try JSONEncoder().encode(requestObject)
//        request.httpBody = requestData

        //        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
        //            if let error = error {
        //                print("There was an error: \(error.localizedDescription)")
        //                return
        //            }
        //
        //            if let data = data {
        //                do {
        //                    let responseObject = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        //
        //                    self?.lastResponseFromChatGPT = responseObject
        //                    print("set lastResponseFromChatGPT")
        //                } catch {
        //                    print("There was an error decoding the JSON object: \(error.localizedDescription)")
        //                }
        //            }
        //
        //            do {
        //                try self?.convertOpenAIResponseToIngredients()
        //            } catch {
        //                print("\(error.localizedDescription)")
        //            }
        //        }
        //
        //        task.resume()
        //        print("Exiting postMessageToCompletionsEndpoint")
//    }

    public func convertOpenAIResponseToIngredients(_ response: OpenAIResponse) throws -> DecodedIngredients {
        let ingredientJSONString = response.choices[0].message.content

        /// Try to convert the JSON string from ChatGPT into a JSON Data object.
        guard let ingredientJSON = ingredientJSONString.data(using: .utf8) else { throw OpenAIError.badJSONString }

        /// Try to decode the JSON object into a DecodedIngredients object.
        let ingredientsObj = try JSONDecoder().decode(DecodedIngredients.self, from: ingredientJSON)

        return ingredientsObj
    }
}
