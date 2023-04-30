//
//  OpenAIService.swift
//  ClipGPT
//
//  Created by tadeckar on 4/29/23.
//

import Foundation
import OpenAI

enum RequestType: String {
    case ask, edit
}
enum RequestResult {
    case completions(CompletionsResult)
    case edits(EditsResult)
}
enum Query {
    case completions(CompletionsQuery)
    case edits(EditsQuery)
}

class OpenAIService {
    private var _apiKey: String
    private var _client: OpenAI
    public var apiKey: String {
        get { return _apiKey }
        set {
            _apiKey = newValue
            _client = OpenAI(apiToken: _apiKey)
        }
    }
    
    init(apiKey: String) {
        _apiKey = apiKey
        _client = OpenAI(apiToken: _apiKey)
    }
    
    public func request(
        requestType: RequestType,
        prompt: String,
        instruction: String? = "",
        maxTokens: Int? = 30
    ) async -> String {
        print(prompt)
        if let uInstruction = instruction { print(uInstruction) }
        var query: Query? = nil
        switch requestType {
        case .ask:
            query = .completions(CompletionsQuery(
                model: .textDavinci_003,
                prompt: prompt,
                temperature: 0,
                maxTokens: maxTokens,
                topP: 1,
                frequencyPenalty: 0,
                presencePenalty: 0,
                stop: ["\\n"]
            ))
        case .edit:
            query = .edits(EditsQuery(
                model: "text-davinci-edit-001",
                input: prompt,
                instruction: instruction!,
                temperature: 0.4
            ))
        }
        do {
            var result: RequestResult? = nil
            switch query {
            case .completions(let completionsQuery):
                let response = try await _client.completions(query: completionsQuery)
                result = .completions(response)
            case .edits(let editsQuery):
                let response = try await _client.edits(query: editsQuery)
                result = .edits(response)
            default:
                result = nil
            }
            print(result as Any)
            var text: String? = ""
            switch result {
            case .completions(let result):
                text = result.choices.first?.text
            case .edits(let result):
                text = result.choices.first?.text
            default:
                text = ""
            }
            return text?.replacing(/^\n*/, with: "") ?? ""
        } catch let error {
            print(error)
            return ""
        }
    }
}
