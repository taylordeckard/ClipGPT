//
//  ContentView.swift
//  ClipGPT
//
//  Created by tadeckar on 4/24/23.
//

import SwiftUI
import KeyboardShortcuts
import OpenAI

func getCompletion(
    apiKey: String,
    prompt: String,
    maxTokens: Int
) async -> String {
    print(apiKey)
    print(prompt)
    let openAI = OpenAI(apiToken: apiKey)
    let query = CompletionsQuery(model: .textDavinci_003, prompt: prompt, temperature: 0, maxTokens: maxTokens, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
    do {
        let result = try await openAI.completions(query: query)
        print(result)
        return result.choices.first?.text.replacing(/^\n*/, with: "") ?? ""
    } catch let error {
        print(error)
        return ""
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
//    @State private var loading = false
    @AppStorage("apiKey") var apiKey: String = ""
    @State private var clipboardText = ""
    @AppStorage("maxTokens") private var maxTokens = 30
    
    var body: some View {
        VStack {
            if appState.loading {
                ProgressView("Loading...")
            } else {
                Text("ClipGPT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Form {
                    KeyboardShortcuts.Recorder("Keyboard Shortcut:", name: .runChatGPT)
                        .frame(width: 600)
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    TextField("Max Tokens", value: $maxTokens, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
            }
        }
        .onAppear{
            KeyboardShortcuts.onKeyDown(for: .runChatGPT) { [] in
                appState.loading = true
                let pasteboard = NSPasteboard.general
                if let string = pasteboard.string(forType: .string) {
                    clipboardText = string
                }
                Task.detached {
                    let result = await getCompletion(apiKey: apiKey, prompt: clipboardText, maxTokens: maxTokens)
                    print(result)
                    pasteboard.clearContents()
                    pasteboard.setString(result, forType: .string)
                   
                    DispatchQueue.main.async {
                        appState.loading = false
                    }
                }
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
