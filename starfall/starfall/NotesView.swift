import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.noteDate, ascending: false)],
        animation: .default
    ) var notes: FetchedResults<Note>
    
    // State to manage the active state of the NavigationLink
    @State private var isAddingNewNote = false
    // State to hold the new note object to be edited
    @State private var newNote: Note?


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
        let newNote = Note(context: viewContext)
        newNote.noteTitle = "New Note"
        newNote.noteBody = ""
        newNote.noteDate = Date()
        self.newNote = newNote
        
        // Trigger the navigation to the NoteEditView
        isAddingNewNote = true
    }

    private func deleteNotes(offsets: IndexSet) {
        // Your implementation for deleting notes
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setup the in-memory persistent container
        let persistentContainer = NSPersistentContainer(name: "starfall") // Replace "YourModel" with the name of your Core Data model file
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // This makes it in-memory
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        // Pass the context to the NotesView
        return NotesView().environment(\.managedObjectContext, persistentContainer.viewContext)
    }
}
