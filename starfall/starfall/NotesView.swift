import SwiftUI
import CoreData

struct NotesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Note.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.noteDate, ascending: false)],
        animation: .default
    ) var notes: FetchedResults<Note>
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.folderName, ascending: true)],
        animation: .default
    ) var folders: FetchedResults<Folder>

    // State to manage the active state of the NavigationLink
    @State private var isAddingNewNote = false
    // State to hold the new note object to be edited
    @State private var newNote: Note?
    
    @State private var showingCreateFolder = false
    @State private var newFolderName = ""
    @State private var selectedFolder: Folder? = nil


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
                Color("bg-color").edgesIgnoringSafeArea(.all)
                List {
                    Section() {
                        ForEach(folders, id: \.self) { folder in
                            Button(action: {
                                // Toggle selection on tap
                                self.selectedFolder = self.selectedFolder == folder ? nil : folder
                            }) {
                                HStack {
                                    Image(systemName: "folder") // System folder icon
                                        .foregroundColor(.yellow) // Color the icon
                                    Text(folder.folderName ?? "Untitled Folder")
                                        .foregroundColor(.white)
                                }
                            }
                            .listRowBackground(Color("bg-color"))

                            // Conditionally display the notes for the selected folder
                            if selectedFolder == folder {
                                ForEach(folder.folderNotes?.allObjects as? [Note] ?? [], id: \.self) { note in
                                    NavigationLink(destination: NoteEditView(note: note)) {
                                        HStack(alignment: .center) {
                                            Image(systemName: "doc")
                                                .foregroundColor(.white)
                                            VStack(alignment: .leading) {
                                                Text(note.noteTitle ?? "Untitled")
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                if let noteBody = note.noteBody, !noteBody.isEmpty {
                                                    Text(noteBody)
                                                        .foregroundColor(.white)
                                                        .font(.subheadline)
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                }
                                            }
                                            .background(Color("bg-color"))
                                        }
                                        .padding(.leading, 40)
                                    }
                                    .listRowBackground(Color("bg-color"))
                                }
                            }
                        }
                    }
                    Section() {
                        ForEach(notes.filter { $0.noteFolder == nil }, id: \.self) { note in
                            NavigationLink(destination: NoteEditView(note: note)) {
                                HStack(alignment: .center) {
                                    Image(systemName: "doc")
                                        .foregroundColor(.white)
                                    VStack(alignment: .leading) {
                                        Text(note.noteTitle ?? "Untitled")
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        if let noteBody = note.noteBody, !noteBody.isEmpty {
                                            Text(noteBody)
                                                .foregroundColor(.white)
                                                .font(.subheadline)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                        }
                                    }
                                    .background(Color("bg-color"))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // This ensures the HStack takes full width
                                .background(Color("bg-color"))
                            }
                            .listRowBackground(Color("bg-color"))
                            .background(Color("bg-color"))
                        }
                        .onDelete(perform: deleteNotes)
                    }
                    .listRowBackground(Color("bg-color"))
                }
                .listStyle(PlainListStyle()) // Use PlainListStyle for the list
                .navigationTitle("Notes")
                .navigationBarItems(trailing: HStack {
                    Button(action: { self.showingCreateFolder = true }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.white)
                    }
                    Button(action: addNote) {
                        Image(systemName: "plus")
                            .foregroundColor(.white) // Set the plus button color to white
                    }
                })
            }
        } // End NavField
        .sheet(isPresented: $showingCreateFolder) {
            // Sheet content for creating a new folder
            NavigationView {
                Form {
                    TextField("Folder Name", text: $newFolderName)
                    Button("Create Folder") {
                        createFolder(named: newFolderName)
                        newFolderName = "" // Reset the folder name
                        showingCreateFolder = false // Dismiss the sheet
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .navigationBarTitle("New Folder", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    showingCreateFolder = false
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
    
    private func createFolder(named name: String) {
        let newFolder = Folder(context: viewContext)
        newFolder.folderName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        newFolder.creationDate = Date()

        do {
            try viewContext.save()
        } catch {
            // Handle the error appropriately
            print("Error saving folder: \(error.localizedDescription)")
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
