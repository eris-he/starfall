import SwiftUI

// Your Note model
struct HealthNote {
    var noteTitle: String
    var noteDate: String
    var noteBody: String
}

// ViewModel to manage notes
class NotesViewModel: ObservableObject {
    @Published var notes: [HealthNote] = []
    
    func addNewNoteWithBody(_ body: String) {
        let newNote = HealthNote(
            noteTitle: "", // Leave the title empty
            noteDate: "", // Leave the date empty
            noteBody: body
        )
        notes.append(newNote)
    }
}
