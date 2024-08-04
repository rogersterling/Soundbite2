import SwiftUI

struct SettingsView: View {
    @AppStorage("anthropicAPIKey") private var anthropicAPIKey: String = ""
    @AppStorage("assemblyAIAPIKey") private var assemblyAIAPIKey: String = ""

    var body: some View {
        Form {
            Section(header: Text("API Keys")) {
                TextField("Anthropic API Key", text: $anthropicAPIKey)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                TextField("AssemblyAI API Key", text: $assemblyAIAPIKey)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section {
                Button("Save") {
                    // The values are automatically saved due to @AppStorage
                    // You can add additional actions here if needed
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}