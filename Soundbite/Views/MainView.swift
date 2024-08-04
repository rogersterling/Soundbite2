import SwiftUI
import AVFoundation
import Foundation

struct MainView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var meals: [Meal] = []
    
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
                
                List(meals) { meal in
                    Text(meal.name)
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
        
        // Here you would typically process the recording
        // Send to AssemblyAI, then to Claude API, then update meals
        // For now, let's just add a dummy meal
        meals.append(Meal(date: Date(), time: "12:00", name: "Recorded Meal", category: "Lunch", ingredients: [], carbLevel: "", carbsGrams: nil, proteinLevel: "", proteinGrams: nil, fatLevel: "", fatGrams: nil, sugarContent: "", sugarGrams: nil, fiberContent: "", fiberGrams: nil, feeling: "", notes: ""))
    }
} 

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}