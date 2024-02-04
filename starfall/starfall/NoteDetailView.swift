import SwiftUI

struct NoteEditView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
            NavigationView {
                ScrollView {
                    VStack {
                        TextField("Title", text: Binding<Any>.safeUnwrap($note.noteTitle, defaultValue: ""))
                            .padding(.horizontal)
                        
                        DatePicker(
                            "Date",
                            selection: Binding<Any>.safeUnwrap($note.noteDate, defaultValue: Date()),
                            displayedComponents: .date
                        )
                        .padding(.horizontal)

                        TextEditor(text: Binding<Any>.safeUnwrap($note.noteBody, defaultValue: ""))
                            .frame(minHeight: 300) // Set minimum height or use geometry reader for dynamic height
                            .padding(.horizontal)
                    }
                }
                .navigationTitle(Binding<Any>.safeUnwrap($note.noteTitle, defaultValue: "New Note").wrappedValue)
                .navigationBarItems(trailing: Button(action: saveNote) {
                    Button(action: saveNote) {
                        Text("Save")
                    }
                    Image(systemName: "checkmark")
                })
            }
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
