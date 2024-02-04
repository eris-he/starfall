import SwiftUI

struct NoteEditView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode // Add this line

    @State private var tempTitle: String = ""

    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
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
                            .font(.custom("Futara-Medium", size: 20))
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
        .background(Color("bg-color")) // Set the background color of NavigationView
        .accentColor(.white) // Set the accent color for the entire view, which affects the DatePicker
    }
    
    private func saveNote() {
        do {
            try viewContext.save()
            self.presentationMode.wrappedValue.dismiss() // Add this line to dismiss the view
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
