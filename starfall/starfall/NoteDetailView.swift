import SwiftUI

struct NoteDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var note: Note

    // Renamed state variables to avoid conflict with 'note.body'
    @State private var noteTitle: String = ""
    @State private var noteBody: String = ""

    var body: some View {
        Form {
            TextField("Title", text: $newTitle)
            TextField("Body", text: $noteBody)
            Button("Save") {
                // Update the note with the new values
                note.title = newTitle
                note.body = noteBody
                
                // Save the context
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        .navigationTitle("Edit Note")
        .onAppear {
            // Initialize the temporary state with the current note values
            noteTitle = note.title ?? ""
            noteBody = note.body ?? ""
        }
    }
}
