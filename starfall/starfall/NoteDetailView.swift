import SwiftUI
import CoreData

struct NoteEditView: View {
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.folderName, ascending: true)],
        animation: .default
    ) var folders: FetchedResults<Folder>

    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode // Add this line
    
    @State private var selectedFolderID: NSManagedObjectID? // State to track the selected folder ID


    @State private var tempTitle: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Image(systemName: "folder") // System folder icon
                            .foregroundColor(.yellow) // Color the icon
                        Text("Current Folder: ") // Add this line
                                .foregroundColor(.white)

                        Picker("Folder", selection: $selectedFolderID) {
                            Text("No Folder").tag(NSManagedObjectID?.none)
                            ForEach(folders, id: \.self) { folder in
                                Text(folder.folderName ?? "Unnamed Folder").tag(folder.objectID as NSManagedObjectID?)
                                    .font(.custom("Futura-Medium", size: 12))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    DatePicker(
                        "Date",
                        selection: Binding<Date>.safeUnwrap($note.noteDate, defaultValue: Date()),
                        displayedComponents: .date
                    )
                    .colorScheme(.dark)
                    .padding()
                    .background(Color("bg-color")) // Set the background color of DatePicker
                    .padding(.horizontal)
                    
                    ZStack {
                        Color("bg-color")
                            .ignoresSafeArea()
                        TextEditor(text: Binding<String>.safeUnwrap($note.noteBody, defaultValue: ""))
                            .foregroundColor(.white) // Set the text color to white
                            .frame(minHeight: 300) // Set minimum height or use geometry reader for dynamic height
                            .padding(.horizontal)
                            .scrollContentBackground(.hidden) // to make background color work
                            .background(Color("bg-color"))
                            .font(.custom("Futura-Medium", size: 20))
                    }
                }
                .background(Color("bg-color")) // Set the background color of VStack
            }
            .background(Color("bg-color")) // Set the background color of ScrollView
            // Replace navigationTitle with a custom view that contains a TextField
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextField(
                        "Title",
                        text: $tempTitle,
                        onCommit: {
                            // Save the temporary title to the note when the user finishes editing
                            note.noteTitle = tempTitle
                            saveNote()
                        }
                    )
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(4)
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Update the note title with the temporary title before saving
                note.noteTitle = tempTitle
                saveNote()
            }) {
                Text("Save")
                Image(systemName: "checkmark")
                    .foregroundColor(.white) // Set the icon color to white
            })
            .background(Color("bg-color"))
            .onAppear {
                // Initialize the temporary title with the current note title
                self.tempTitle = note.noteTitle ?? ""
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.indigo,
                               // 2
                               for: .navigationBar)
        }
        .onAppear {
            self.tempTitle = note.noteTitle ?? ""
            self.selectedFolderID = note.noteFolder?.objectID // Set the initial folder based on the note's current folder
        }
        .background(Color("bg-color")) // Set the background color of NavigationView
        .accentColor(.white) // Set the accent color for the entire view, which affects the DatePicker
    }
    
    private func saveNote() {
        // Find the selected folder by its ID
        if let folderID = selectedFolderID,
           let folder = viewContext.object(with: folderID) as? Folder {
            note.noteFolder = folder
        } else {
            note.noteFolder = nil // If no folder is selected, set to nil
        }
        
        // Continue with your existing save logic
        do {
            try viewContext.save()
            self.presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save note: \(error.localizedDescription)")
            // Handle the error appropriately
        }
    }

}

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .cornerRadius(10)
    }
}

extension Binding {
    /// Creates a non-optional binding from an optional binding, replacing nil with a default value.
    static func safeUnwrap<Value>(_ binding: Binding<Value?>, defaultValue: Value) -> Binding<Value> {
        return Binding<Value>(
            get: { binding.wrappedValue ?? defaultValue },
            set: { binding.wrappedValue = $0 }
        )
    }
}
