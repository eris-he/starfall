import SwiftUI

struct NoteEditView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    TextField("Title", text: Binding<String>.safeUnwrap($note.noteTitle, defaultValue: ""))
                        .foregroundColor(.white) // Set the text color to white
                        .padding()
                        .background(Color("bg-color")) // Set the background color of TextField
                        .padding(.horizontal)

                    DatePicker(
                        "Date",
                        selection: Binding<Date>.safeUnwrap($note.noteDate, defaultValue: Date()),
                        displayedComponents: .date
                    )
                    .foregroundColor(.white) // This sets the label color to white
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
                            
                    }

                }
                .background(Color("bg-color")) // Set the background color of VStack
            }
            .background(Color("bg-color")) // Set the background color of ScrollView
            .navigationTitle(Binding<String>.safeUnwrap($note.noteTitle, defaultValue: "New Note").wrappedValue)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: saveNote) {
                Text("Save")
                Image(systemName: "checkmark")
                    .foregroundColor(.white) // Set the icon color to white
            })
//            .navigationBarItems(trailing: Button("Save", action: saveNote)
//                .foregroundColor(.white) // Set the button text color to white
//            )
        }
        .background(Color("bg-color")) // Set the background color of NavigationView
        .accentColor(.white) // Set the accent color for the entire view, which affects the DatePicker
    }
    
    private func saveNote() {
        do {
            try viewContext.save()
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
