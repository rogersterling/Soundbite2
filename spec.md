# Complete iOS Diet Tracking App Specification

## 1. App Overview

The iOS Diet Tracking App allows users to record audio descriptions of their meals and feelings on a single screen. These recordings are then processed to create a log of dietary habits and well-being.

## 2. Key Features

- Audio recording of meal descriptions on the main screen
- Integration with AssemblyAI for speech-to-text transcription
- Integration with Claude API for natural language processing
- Local storage of processed data
- Display of dietary information
- Settings for API key management

## 3. Technical Stack

- iOS (Swift)
- SwiftUI
- UserDefaults for simple data storage
- AVFoundation for audio recording
- URLSession for networking

## 4. User Flow

1. User opens the app
2. User enters their Anthropic and AssemblyAI API keys in settings
3. User records an audio description of their meal on the main screen
4. App sends audio to AssemblyAI for transcription
5. App sends transcription to Claude API for processing
6. App stores and displays processed data on the main screen

## 5. Data Processing

### 5.1 AssemblyAI Integration

- Implement AssemblyAI API calls for audio transcription
- Use URLSession for API requests
- Endpoint: https://api.assemblyai.com/v2/transcript
- Refer to AssemblyAI documentation for detailed API usage

### 5.2 Claude API Integration

- Implement Claude API calls for natural language processing
- Use URLSession for API requests
- Endpoint: https://api.anthropic.com/v1/messages
- Use the following prompt for Claude:

```
Below is a transcription of the user's food consumption and health-related experiences for today or a recent day. Please analyze the transcript and create a JSON output that describes it. Only include properties that are explicitly mentioned or can be clearly inferred from the transcript. Leave properties blank if they are not mentioned or cannot be confidently inferred.

Here's the JSON structure to use:

{
  "what_consumed": [
    {
      "date": "",
      "time": "",
      "name": "",
      "category": "",
      "ingredients": [],
      "carb_level": "",
      "carbs_g": null,
      "protein_level": "",
      "protein_g": null,
      "fat_level": "",
      "fat_g": null,
      "sugar_content": "",
      "sugar_g": null,
      "fiber_content": "",
      "fiber_g": null,
      "feeling": "",
      "notes": ""
    }
  ]
}

Notes:
- The "what_consumed" array may contain multiple entries if more than one meal is described.
- Use null for numeric fields (e.g., carbs_g) when no specific value is provided.
- Only include properties that have a value; omit empty strings or null values.
- Infer the "category" (e.g., breakfast, lunch, dinner, snack) from context if possible.
- The "feeling" field should capture the user's emotional or physical state related to the meal.
- The "notes" field should include any additional relevant information about the meal or experience.

Please process the following transcript:

[Transcript goes here]
```

## 6. Data Storage

- Use UserDefaults for storing meal entries and API keys
- Create a simple data model that mirrors the JSON structure returned by Claude API

## 7. User Interface

### 7.1 Main Screen
- "Record" button at the top
- Audio recording interface with start/stop controls
- List view of recorded meals below the recording controls
- Navigation link to Settings view

### 7.2 Settings Screen
- Input fields for Anthropic and AssemblyAI API keys
- Save button to store API keys

## 8. Error Handling

- Display alert messages for API errors or missing keys

## 9. High-Level Development Plan

1. Set up the project:
   - Create a new SwiftUI project in Xcode
   - Set up basic folder structure: Views, Models, Services

2. Implement the Main View:
   - Create a SwiftUI view with a "Record" button, recording controls, and a list
   - Use @State variables to manage recording state and meal entries
   - Implement audio recording functionality using AVFoundation

3. Implement the Settings View:
   - Create input fields for API keys
   - Use @AppStorage to persist API keys in UserDefaults

4. Create a simple Meal model:
   - Define a struct that matches the JSON structure from Claude

5. Implement AssemblyAI Service:
   - Create a function to send audio file to AssemblyAI
   - Use URLSession for the API request

6. Implement Claude API Service:
   - Create a function to send transcription to Claude API
   - Use URLSession for the API request
   - Include the Claude prompt in the request

7. Connect everything:
   - After recording on the main screen, call AssemblyAI service
   - After transcription, call Claude API service
   - Update the meal list with the processed data

8. Add basic error handling:
   - Display alerts for API errors or missing keys

9. Polish the UI:
   - Improve layout and styling of the main screen
   - Add loading indicators during processing

## 10. Additional Notes

- Ensure all API calls use the keys stored in UserDefaults
- The app should handle cases where API keys are not yet set
- Consider adding a simple onboarding process to guide users through setting up their API keys
- Remember to handle potential network issues gracefully
- Playback functionality for recorded audio can be considered as a future enhancement

This specification provides a comprehensive guide for developing the iOS Diet Tracking App. It includes all necessary details, including the Claude prompt, to ensure the developer has everything needed to implement the app's core functionality.
