import SwiftUI

struct HealthView: View {
    @State private var userInput: String = ""
    @State private var sleepRating: Int = 5
    @State private var isSaved: Bool = false

    var body: some View {
        ZStack {
            Color("bg-color") // Background color
            
            VStack {
                
                Spacer()
                
                // PNG image with transparent background
                ZStack {
                    Image("sun") // Replace "your_image" with the name of your PNG image asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 360, height: 360)
                        .padding()
                        .cornerRadius(10)
                        .shadow(color: .blue, radius: 10, x: 0, y: 0) // Add shadow effect
                    
                }
                
                Text("How are you feeling today?")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 10) // Move the text up by adding top padding

                TextField("Enter here", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("How was your sleep?")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 10) // Move the text up by adding top padding
                
                Picker(selection: $sleepRating, label: Text("Sleep Rating")) {
                    ForEach(1..<11) { rating in
                        Text("\(rating)")
                            .foregroundColor(.black) // Set text color to black
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Use segmented picker style
                .padding()
                .foregroundColor(.white)
                .background(Color.indigo)
                Button(action: {
                    saveToFile()
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.indigo)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(userInput.isEmpty) // Disable button if user input is empty

                if isSaved {
                    Text("Data saved successfully")
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func saveToFile() {
        guard !isSaved else {
            print("File already saved")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss" // Define the date format

        let fileName = "Health-\(formatter.string(from: Date())).txt"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        do {
            let data = "\(userInput)\nSleep Rating: \(sleepRating)"
            try data.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Data saved to file: \(fileURL)")
            isSaved = true

            // Reset isSaved after a delay
            Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { timer in
                isSaved = false
            }
        } catch {
            print("Error saving data to file: \(error)")
        }
    }
}
