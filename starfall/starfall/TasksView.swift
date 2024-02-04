//
//  TasksView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.taskCheckbox, ascending: true),
            NSSortDescriptor(keyPath: \Task.taskCreatedTime, ascending: true)],
        animation: .default)
    var tasks: FetchedResults<Task>
    
    // State for new task input
    @State private var newTaskContent = ""
    
    var body: some View {
        ZStack {
            Color("bg-color").ignoresSafeArea()
            
            VStack {
                Text("Tasks")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size: 42))
                
                // List of tasks
                List {
                    ForEach(tasks) { task in
                        SingleTaskView(task: task)
                            .listRowBackground(Color("bg-color"))
                            .listRowSeparator(Visibility.visible)
                    }
                    .onDelete(perform: deleteTask)
                    
                    // This is the text field add button
                    HStack {
                        ZStack {
                            
                            Color("textbox-color").cornerRadius(8)
                            
                            if newTaskContent.isEmpty {
                                HStack{
                                    Text("New task")
                                        .foregroundColor(.gray) // Placeholder text color
                                        .padding(.leading, 5)
                                    Spacer()
                                }
                            }
                            
                            TextField("", text: $newTaskContent)
                                .foregroundColor(.white) // Text color
                                .padding(5)
                        }
                        .frame(height: 36)
                        
                        Button(action: addTask) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .background(Color("bg-color"))
                    .listRowBackground(Color("bg-color"))
                    
                    
                }
                .listStyle(PlainListStyle())
                .background(Color("bg-color"))
            }
            .background(Color("bg-color").edgesIgnoringSafeArea(.all))
        }
    }
    
    private func addTask() {
        withAnimation {
            let newTask = Task(context: viewContext)
            newTask.taskContent = newTaskContent
            newTask.taskCreatedTime = Date()
            newTask.taskCheckbox = false
            newTask.taskCompletedTime = nil // Since the task is not completed yet
            
            // Clear the input field
            newTaskContent = ""
            
            do {
                try viewContext.save()
            } catch {
                // Handle the save error
                print("Failed to save the new task: \(error)")
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            viewContext.delete(task)
        }
        
        do {
            try viewContext.save()
        } catch {
            // Handle the error, e.g., log it or display an alert
            print("Error deleting task: \(error)")
        }
    }
}

struct SingleTaskView: View {
    @ObservedObject var task: Task
    @Environment(\.managedObjectContext) var viewContext

    // State to manage collapsible text
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            HStack (alignment: .top) {
                // Checkbox representation
                Button(action: {
                    // Toggle task completion status
                    task.taskCheckbox.toggle()

                    // If task is now completed, set the completion time
                    if task.taskCheckbox {
                        task.taskCompletedTime = Date()
                    } else {
                        task.taskCompletedTime = nil
                    }

                    // Save context
                    try? viewContext.save()
                }) {
                    Image(systemName: task.taskCheckbox ? "checkmark.square.fill" : "square")
                        .foregroundColor(task.taskCheckbox ? .green : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())

                // Collapsible Text with conditional styling
                Text(task.taskContent ?? "")
                    .lineLimit(isExpanded ? nil : 1)
                    .foregroundColor(task.taskCheckbox ? .gray : .white) // Greyed out if completed
                    .strikethrough(task.taskCheckbox, color: .gray) // Strikethrough if completed
                    .onTapGesture {
                        // Expand or collapse text
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                    
                Spacer()
            }
            Divider()
                .background(Color("separator-color"))
                .padding(0)
        }
        
    }
}



struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
