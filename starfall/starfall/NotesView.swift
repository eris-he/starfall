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

    init() {
            // Configure the appearance of the navigation bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(named: "YourDarkBlueColor") // Your dark blue color
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            // Apply appearance to all navigation bar sizes
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance

            // Set the color for the back button and other bar button items
            UINavigationBar.appearance().tintColor = .white
        }
    var body: some View {
        NavigationView {
            ZStack {
                // Set the background color for the entire ZStack
                Color("bg-color").edgesIgnoringSafeArea(.all)

                List {
                    ForEach(notes, id: \.self) { note in
                        VStack {
                            NavigationLink(destination: NoteEditView(note: note)) {
                                VStack(alignment: .leading) {
                                    Text(note.noteTitle ?? "Untitled")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text(note.noteBody ?? "No content")
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                            .background(Color("bg-color")) // Ensure background extends to edges
                            Divider()
                                .background(Color("separator-color"))
                                .padding(0)
                        }
                        .listRowBackground(Color("bg-color"))
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(PlainListStyle()) // Use PlainListStyle for the list
                .navigationTitle("Notes")
                .navigationBarItems(trailing: Button(action: addNote) {
                    Image(systemName: "plus")
                        .foregroundColor(.white) // Set the plus button color to white
                })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
        print("test")
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Handle the error appropriately
                print(error.localizedDescription)
            }
        }
    }
}

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        // Setup the in-memory persistent container
        let persistentContainer = NSPersistentContainer(name: "starfall")
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
