import SwiftUI
import CoreData
import UIKit

struct HealthView: View {
    @State private var userInput: String = ""
    @State private var sleepRating: Int = 5
    @State private var isSaved: Bool = false
    
    @StateObject private var notesViewModel = NotesViewModel() // Instantiate the ViewModel
    @Environment(\.presentationMode) var presentationMode // Add this line

    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            ZStack {
                Color("bg-color") // Background color
                    .ignoresSafeArea()
                VStack {
                    
                    // PNG image with transparent background
                        Image("sun") // Replace "your_image" with the name of your PNG image asset
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .shadow(color: .blue, radius: 10, x: 0, y: 0) // Add shadow effect
                            .padding(.top, 80) // Move the text up by adding top padding


                    
                    Text("How are you feeling today?")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 40) // Move the text up by adding top padding
                    
                    TextField("Enter here...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing, 30)
                        .padding(.leading, 30)
                    
                    Text("How was your sleep?")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 35) // Move the text up by adding top padding


                    
                    Picker(selection: $sleepRating, label: Text("Sleep Rating")) {
                        ForEach(1..<11) { rating in
                            Text("\(rating)")
                                .foregroundColor(.black) // Set text color to black
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle()) // Use segmented picker style
                    .foregroundColor(Color.white)
                    .background(Color.indigo)
                    .padding(.trailing, 30)
                    .padding(.leading, 30)

                    
                    if isSaved {
                        Text("Data saved successfully")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Ensures that the title is in line with the toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Journal")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Your save action here
                        saveToFile()
                    }) {
                        HStack {
                            Text("Save")
                                .foregroundColor(.white)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.indigo,
                               // 2
                               for: .navigationBar)
            
        }
    }
    
    
    private func saveToFile() {
        guard !isSaved else {
            print("Note already saved")
            return
        }
        let healthFolder = findOrCreateFolder(named: "Health Notes")

        let newNote = Note(context: viewContext) // Use the same viewContext that is injected into the environment
        newNote.noteTitle = "Health Note"
        newNote.noteBody = "Mood: \(userInput)\nSleep Rating: \(sleepRating+1)"
        newNote.noteDate = Date()
        newNote.noteFolder = healthFolder // Assign the note to the "Health Notes" folder

        do {
            try viewContext.save()
            print("Note saved to CoreData")
            isSaved = true
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving note to CoreData: \(error)")
        }
    }
    
    private func findOrCreateFolder(named folderName: String) -> Folder {
        // Check if the folder already exists
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "folderName == %@", folderName)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            if let existingFolder = results.first {
                // If the folder exists, return it
                return existingFolder
            } else {
                // If the folder does not exist, create a new one
                let newFolder = Folder(context: viewContext)
                newFolder.folderName = folderName
                newFolder.creationDate = Date()
                return newFolder
            }
        } catch {
            print("Error fetching folder: \(error)")
            // If an error occurs, create a new folder to ensure the function returns a Folder object
            let newFolder = Folder(context: viewContext)
            newFolder.folderName = folderName
            newFolder.creationDate = Date()
            return newFolder
        }
    }
}
