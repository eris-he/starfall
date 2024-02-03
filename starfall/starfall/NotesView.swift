import SwiftUI

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.noteDate, ascending: false)],
        animation: .default
    ) var notes: FetchedResults<Note>

    var body: some View {
        NavigationView {
            List {
                ForEach(notes, id: \.self) { note in
                    NavigationLink(destination: NoteEditView(note: note)) {
                        VStack(alignment: .leading) {
                            Text(note.noteTitle ?? "Untitled")
                                .font(.headline)
                            Text(note.noteBody ?? "No content")
                                .font(.subheadline)
                            // If you want to show the date as well, you can add it here.
                        }
                    }
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .navigationBarItems(trailing: Button(action: addNote) {
                Image(systemName: "plus")
            })
        }
    }

    private func addNote() {
        // Your implementation for adding a new note
    }

    private func deleteNotes(offsets: IndexSet) {
        // Your implementation for deleting notes
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        // You might need to set up a preview context for Core Data
        NotesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
