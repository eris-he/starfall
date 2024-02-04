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
                Section {
                    Text("Tasks")
                        .foregroundColor(.white)
                        .font(.custom("Futura-Medium", size: 42))
                }
                
                // List of tasks
                List {
                    ForEach(tasks) { task in
                        ZStack() {
                            SingleTaskView(task: task)
                                .background(Color("bg-color"))
                        }
                        .padding(.bottom, 13)
                        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                        .listRowBackground(Color("bg-color"))
                    }
                    .onDelete(perform: deleteTask)
                
                    
                    // This is the text field add button
                    HStack {
                        ZStack {
                            Color("textbox-color").cornerRadius(8)
                            
                            if newTaskContent.isEmpty {
                                HStack {
                                    Text("New task")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 15) // Adjusted for uniform padding
                                    Spacer()
                                }
                            }
                            
                            TextField("", text: $newTaskContent)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15) // Adjust padding to match the placeholder text
                                .padding(.vertical, 5) // Ensure vertical padding does not exceed ZStack's frame height
                        }
                        Button(action: addTask) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .padding(.horizontal, 4)
                        }
                        .buttonStyle(PlainButtonStyle())

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
            let newStar = Star(context: viewContext) // Create a new Star entity
            
            // Configure the Task entity
            newTask.taskContent = newTaskContent
            newTask.taskCreatedTime = Date()
            newTask.taskCheckbox = false
            newTask.taskCompletedTime = nil
            
            // Associate the Task with the Star
            newTask.star = newStar // Assuming 'star' is the relationship name in Task entity
            
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
            HStack {
                // Checkbox representation
                Button(action: {
                    // Save context function to avoid redundancy
                    func saveContext() {
                        do {
                            try viewContext.save()
                        } catch {
                            print("Error saving context: \(error.localizedDescription)")
                        }
                    }

                    // Toggle task completion status
                    task.taskCheckbox.toggle()
                    saveContext()
                    
                    if task.taskCheckbox {
                        task.taskCompletedTime = Date()

                        // Fetch the most recent WeeklyStarFarm
                        let fetchRequest: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: false)]
                        fetchRequest.fetchLimit = 1

                        do {
                            let results = try viewContext.fetch(fetchRequest)
                            if let mostRecentWeeklyStarFarm = results.first {
                                // Fetch the star's currently associated WeeklyStarFarm for comparison
                                let starWeeklyStarFarm = task.star?.weekFarm
                                
                                if starWeeklyStarFarm == mostRecentWeeklyStarFarm {
                                    // If the star's associated WeeklyStarFarm is the most recent one
                                    task.star?.isVisible = true // Only toggle visibility
                                } else {
                                    // If the star does not have an associated WeeklyStarFarm, or it's not the most recent
                                    task.star?.weekFarm = mostRecentWeeklyStarFarm
                                    task.star?.isVisible = true
                                    
                                    // Assign new position to the star if it's being associated with a new WeeklyStarFarm
                                    if task.star?.weekFarm != starWeeklyStarFarm {
                                        assignPositionToStar(task.star!, in: mostRecentWeeklyStarFarm, context: viewContext)
                                    }
                                }
                            }
                        } catch {
                            print("Failed to fetch the most recent WeeklyStarFarm: \(error)")
                        }
                    } else {
                        task.taskCompletedTime = nil
                        
                        task.star?.isVisible = false // Set isVisible to false
                        
                        // Fetch the most recent WeeklyStarFarm
                        let fetchRequest: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
                        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "week", ascending: false)]
                        fetchRequest.fetchLimit = 1
                        
                        do {
                            let results = try viewContext.fetch(fetchRequest)
                            if let mostRecentWeeklyStarFarm = results.first, mostRecentWeeklyStarFarm != task.star?.weekFarm {
                                // If the associated WeeklyStarFarm is not the most recent, remove association and reset attributes
                                task.star?.weekFarm = nil
                                task.star?.x = 0
                                task.star?.y = 0
                            }
                        } catch {
                            print("Failed to fetch the most recent WeeklyStarFarm: \(error)")
                        }
                        
                        // Save the updated context if only the completion time was updated
                        saveContext()
                    }
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
        }
    }
    
    // Assuming a structure to manage the cache
    struct PositionCache {
        var occupied: [[Bool]]
        let rows: Int
        let columns: Int

        init(canvasWidth: Int, canvasHeight: Int, starSize: Int) {
            self.rows = canvasHeight / starSize
            self.columns = canvasWidth / starSize
            self.occupied = Array(repeating: Array(repeating: false, count: columns), count: rows)
        }

        mutating func updateCache(with starsSet: Set<Star>, starSize: Int) {
            for star in starsSet {
                let position = CGPoint(x: CGFloat(star.x), y: CanvasDimensions.shared.height - CGFloat(star.y))
                let x = Int(position.x)
                let y = Int(position.y)
                if x < columns && y < rows {
                    occupied[y][x] = true
                }
            }
        }

        func findUnoccupiedPosition() -> (x: Int, y: Int)? {
            var potentialPositions: [(Int, Int)] = []
            for row in 0..<rows {
                for column in 0..<columns {
                    if !occupied[row][column] {
                        potentialPositions.append((column, row))
                    }
                }
            }
            return potentialPositions.randomElement()
        }
    }

    // Use the cache in your function
    func assignPositionToStar(_ star: Star, in weeklyStarFarm: WeeklyStarFarm, context: NSManagedObjectContext, starSize: Int = 30, canvasWidth: Int = Int(CanvasDimensions.shared.width), canvasHeight: Int = Int(CanvasDimensions.shared.height) - 125) {
        guard let starsSet = weeklyStarFarm.stars as? Set<Star> else { return }

        // Initialize and populate the cache
        var cache = PositionCache(canvasWidth: canvasWidth, canvasHeight: canvasHeight, starSize: starSize)
        cache.updateCache(with: starsSet, starSize: starSize)

        // Find an unoccupied position using the cache
        if let position = cache.findUnoccupiedPosition() {
            let adjustedX = position.x * starSize + starSize / 2
            let adjustedY = position.y * starSize + starSize / 2 - 250
            star.x = Int16(adjustedX)
            star.y = Int16(adjustedY)
        } else {
            // Handle the case where no position is found
            print("Canvas is full or no available position found.")
        }
    }
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
