import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest to retrieve Note entities, sorted by an attribute, e.g., 'date'
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.noteDate, ascending: false)],
        animation: .default
    ) var notes: FetchedResults<Note>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notes, id: \.self) { note in
                    VStack(alignment: .leading) {
                        Text(note.noteTitle ?? "Untitled") // Assuming 'title' is an optional string
                            .font(.headline)
                        Text(note.noteBody ?? "No content") // Assuming 'body' is an optional string
                            .font(.subheadline)
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
    
    // Function to delete notes
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            let context = PersistenceController.shared.container.viewContext // Adjust this line to match how you access your Core Data context
            offsets.forEach { index in
                let noteToDelete = notes[index]
                context.delete(noteToDelete)
            }
            
            do {
                try context.save()
            } catch {
                // Handle the Core Data error
                print("Error saving context after deleting notes: \(error.localizedDescription)")
            }
        }
    }
    
    private func addNote() {
        let newNote = Note(context: viewContext)
        newNote.noteTitle = "New Note"
        newNote.noteBody = "This is a newly added note."
        newNote.noteDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
            print(error.localizedDescription)
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        // You might need to setup a preview context for Core Data
        NotesView()
    }
}
