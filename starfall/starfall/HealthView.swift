//
//  HealthView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct HealthView: View {
    @State private var userInput: String = ""
    @State private var isSaved: Bool = false

    var body: some View {
        ZStack {
            Color("bg-color") // Background color
            
            VStack {
                Text("How are you feeling today?")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 100) // Move the text up by adding top padding

                TextField("Enter here", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
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
                                } else {
                                    Text("Data was not saved")
                                        .foregroundColor(.white)
                                        .padding()
                                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    private func saveToFile() {
        let fileName = "user_input.txt"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        do {
            try userInput.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Data saved to file: \(fileURL)")
            isSaved = true

            // Reset isSaved after a delay
            Timer.scheduledTimer(withTimeInterval: 600, repeats: false) { timer in
                        isSaved = false
            }
        } catch {
            print("Error saving data to file: \(error)")
        }
    }


}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
