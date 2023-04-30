//
//  ContentView.swift
//  ClipGPT
//
//  Created by tadeckar on 4/24/23.
//

import SwiftUI
import KeyboardShortcuts
import OpenAI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("storedAskPrefix", store: .standard) private var storedAskPrefix: String = ""
    @AppStorage("storedApiKey") private var storedApiKey: String = ""
    @AppStorage("storedMaxTokens") private var storedMaxTokens = 30
    @AppStorage("storedEditInstruction") private var storedEditInstruction: String = ""
    @State private var apiKey = ""
    @State private var askPrefix = ""
    @State private var clipboardText = ""
    @State private var editInstruction = ""
    @State private var maxTokens = 30
    @State private var openAIService: OpenAIService? = nil
    
    init() {
        _openAIService = State(initialValue: OpenAIService(apiKey: storedApiKey))
    }
    
    private func handleKeydown(requestType: RequestType) {
        appState.loading = true
        let pasteboard = NSPasteboard.general
        if let string = pasteboard.string(forType: .string) {
            if requestType == .ask && !askPrefix.isEmpty {
                clipboardText = askPrefix + " " + string
            } else {
                clipboardText = string
            }
        }
        Task.detached {
            var result: String = ""
            switch requestType {
            case .ask:
                result = await openAIService!.request(
                    requestType: .ask,
                    prompt: clipboardText,
                    maxTokens: maxTokens
                )
            case .edit:
                result = await openAIService!.request(
                    requestType: .edit,
                    prompt: clipboardText,
                    instruction:  editInstruction
                )
            }
            print(result)
            pasteboard.clearContents()
            pasteboard.setString(result, forType: .string)
           
            DispatchQueue.main.async {
                appState.loading = false
            }
        }
    }
    
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
                    KeyboardShortcuts.Recorder("Ask Shortcut", name: .askChatGPT)
                        .frame(width: 600)
                    KeyboardShortcuts.Recorder("Edit Shortcut", name: .editChatGPT)
                        .frame(width: 600)
                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: apiKey) { value in
                            storedApiKey = value
                            if let unwrappedOpenAIService = openAIService {
                                unwrappedOpenAIService.apiKey = value
                            }
                        }
                    TextField("Ask Prefix", text: $askPrefix)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: askPrefix) { value in
                            storedAskPrefix = value
                        }
                    TextField("Edit Instruction", text: $editInstruction)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: editInstruction) { value in
                            storedEditInstruction = value
                        }
                    TextField("Max Tokens", value: $maxTokens, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onChange(of: maxTokens) { value in
                            storedMaxTokens = value
                        }
                }
            }
        }
        .onAppear{
            apiKey = storedApiKey
            askPrefix = storedAskPrefix
            editInstruction = storedEditInstruction
            maxTokens = storedMaxTokens
            KeyboardShortcuts.onKeyDown(for: .askChatGPT) { [] in
                handleKeydown(requestType: .ask)
            }
            KeyboardShortcuts.onKeyDown(for: .editChatGPT) { [] in
                handleKeydown(requestType: .edit)
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
