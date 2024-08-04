import SwiftUI
import AVFoundation
import Foundation

struct MainView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var meals: [Meal] = []
    @State private var isProcessing = false
    @AppStorage("anthropicAPIKey") private var anthropicAPIKey: String = ""
    @AppStorage("assemblyAIAPIKey") private var assemblyAIAPIKey: String = ""
    @State private var apiResponse: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(isRecording ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isProcessing)
                
                if isProcessing {
                    ProgressView("Processing...")
                }
                
                ScrollView {
                    Text(apiResponse)
                        .padding()
                }
                
                List(meals) { meal in
                    VStack(alignment: .leading) {
                        Text(meal.name)
                            .font(.headline)
                        Text(meal.category)
                            .font(.subheadline)
                        Text("Feeling: \(meal.feeling)")
                            .font(.subheadline)
                    }
                }
                
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                }
            }
            .navigationTitle("Soundbite")
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording.m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        isProcessing = true
        apiResponse = "Processing..."
        
        let hardcodedTranscript = """
        Okay, let me walk you through my meals yesterday. I started the day with breakfast around 7:30 AM. I had a bowl of oatmeal with sliced banana, a drizzle of honey, and a sprinkle of cinnamon. I also had a cup of black coffee.
        For a mid-morning snack around 10 AM, I munched on a small handful of almonds and an apple.
        Lunchtime rolled around at 12:30 PM. I made myself a turkey sandwich on whole wheat bread with lettuce, tomato, and a bit of mustard. On the side, I had some baby carrots and hummus.
        In the afternoon, around 3 PM, I felt a bit peckish, so I had a Greek yogurt with a few berries mixed in.
        Dinner was at 7 PM. I cooked some grilled chicken breast seasoned with herbs, alongside roasted vegetables - mainly broccoli and sweet potato. I also had a small side salad with mixed greens and a light vinaigrette dressing.
        Before bed, around 9:30 PM, I treated myself to a small square of dark chocolate.
        Throughout the day, I mainly drank water, probably about 6-8 glasses in total. I also had that morning coffee and a cup of green tea in the afternoon.
        """
        
        let claudeService = ClaudeService(apiKey: anthropicAPIKey)
        claudeService.processTranscription(hardcodedTranscript) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let mealEntry):
                    self.meals.append(contentsOf: mealEntry.whatConsumed)
                    self.apiResponse = "Success: Added \(mealEntry.whatConsumed.count) new meals. Total meals: \(self.meals.count)\n\nAPI Response:\n\(mealEntry)"
                case .failure(let error):
                    self.apiResponse = "Error processing transcription: \(error.localizedDescription)\n\nPlease check the console for the raw API response."
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}