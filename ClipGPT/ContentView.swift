//
//  ContentView.swift
//  ClipGPT
//
//  Created by tadeckar on 4/24/23.
//

import SwiftUI
import KeyboardShortcuts
import OpenAI

func getCompletion(apiKey: String, prompt: String) async -> String {
    print(apiKey)
    print(prompt)
    let openAI = OpenAI(apiToken: apiKey)
    let query = CompletionsQuery(model: .textDavinci_003, prompt: prompt, temperature: 0, maxTokens: 30, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
    do {
        let result = try await openAI.completions(query: query)
        print(result)
        return result.choices.first?.text.replacingOccurrences(of: "\n", with: "") ?? ""
    } catch let error {
        print(error)
        return ""
    }
}

struct ContentView: View {
    @AppStorage("apiKey") var apiKey: String = ""
    @State private var clipboardText = ""
    @State private var loading = false
    
    var body: some View {
        VStack {
            Text("ClipGPT")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            if loading {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
            }
            Form {
                KeyboardShortcuts.Recorder("Keyboard Shortcut:", name: .runChatGPT)
                    .frame(width: 600)
                SecureField("API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
        }
        .onAppear{
            KeyboardShortcuts.onKeyDown(for: .runChatGPT) { [] in
                loading = true
                let pasteboard = NSPasteboard.general
                if let string = pasteboard.string(forType: .string) {
                    clipboardText = string
                }
                Task.detached {
                    let result = await getCompletion(apiKey: apiKey, prompt: clipboardText)
                    pasteboard.clearContents()
                    pasteboard.setString(result, forType: .string)
                    loading = false
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
