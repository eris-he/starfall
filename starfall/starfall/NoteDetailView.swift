import SwiftUI

struct NoteEditView: View {
    @ObservedObject var note: Note
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        Form {
            TextField("Title", text: Binding<Any>.safeUnwrap($note.noteTitle, defaultValue: ""))
            TextField("Body", text: Binding<Any>.safeUnwrap($note.noteBody, defaultValue: ""))
            DatePicker(
                "Date",
                selection: Binding<Any>.safeUnwrap($note.noteDate, defaultValue: Date()),
                displayedComponents: .date
            )
            Button("Save") {
                saveNote()
            }
            .buttonStyle(PressedButtonStyle())
        }
        .navigationTitle("Edit Note")
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
