//
//  ContentView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    let persistenceController = PersistenceController.shared
    
    init() {
        ensureWeeklyStarFarmExists(for: Date(), in: persistenceController.container.viewContext)
    }
    
    let buttons = [
        ("Tasks", "planet-1"),
        ("Calendar", "planet-4"),
        ("Notes", "planet-3"),
        ("Health", "planet-2"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("bg-color")
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    // Star garden area with the separate "Focus" button
                    starGarden()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                    
//                    Divider()
//                        .background(Color.white)
//                        .padding(.horizontal)
                    
                    // Grid layout for the rest of the buttons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                        ForEach(buttons, id: \.0) { button in
                            navigationButton(label: button.0, imageName: button.1)
                        }
                    }
                    .padding(.horizontal)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .padding(.top, 5)

                }
            }
        }
    }
    
    @ViewBuilder
    private func starGarden() -> some View {
        ZStack {

            StarFarm()

            VStack{
                Spacer() 
                NavigationLink(destination: FocusView()) {
                    Text("Focus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue) // Customize the background color
                        .cornerRadius(10)
                        .font(.custom("Futura-Medium", size: 24))
                }
                .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to prevent button highlighting effect
            }
        }
    }
    
    private func navigationButton(label: String, imageName: String) -> some View {
        var imageWidth: CGFloat = 100 // Default width
        var imageHeight: CGFloat = 100 // Default height
        
        if label == "Tasks" {
            imageWidth = 170 // Adjust width for "Tasks" label
            imageHeight = 170 // Adjust height for "Tasks" label
        } else if label == "Calendar" {
            imageWidth = 130 // Adjust width for "Calendar" label
            imageHeight = 130 // Adjust height for "Calendar" label
        } else if label == "Notes" {
            imageWidth = 130 // Adjust width for "Label3" label
            imageHeight = 130 // Adjust height for "Label3" label
        } else if label == "Health" {
            imageWidth = 180 // Adjust width for "Label4" label
            imageHeight = 150 // Adjust height for "Label4" label
        }

        return NavigationLink(destination: destinationView(for: label)) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .frame(width: imageWidth, height: imageHeight) // Use the individual width and height for each label
                    .foregroundColor(.white)
                    .opacity(0.7)
                Text(label)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .bold()
                    .font(.custom("Futura-Medium", size: 24))
            }
//            .padding()
//            .ignoresSafeArea(.container, edges: .bottom)
            .frame(maxWidth: .infinity)
            .background(Color("bg-color"))
            .cornerRadius(1)


        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Function to return the appropriate destination view
    private func destinationView(for label: String) -> some View {
        switch label {
        case "Tasks":
            return AnyView(TasksView())
        case "Calendar":
            return AnyView(CalendarView())
        case "Focus":
            return AnyView(FocusView())
        case "Notes":
            return AnyView(NotesView())
        case "Health":
            return AnyView(HealthView())
        default:
            return AnyView(Text("Not Implemented"))
        }
    }
}

func dateOfLastSunday() -> Date {
    let calendar = Calendar.current
    let today = Date()
    let weekday = calendar.component(.weekday, from: today)
    // Calculate the difference from today to the last Sunday
    let daysToSubtract = weekday == 1 ? 0 : -(weekday - 1)
    let lastSunday = calendar.date(byAdding: .day, value: daysToSubtract, to: today)!
    
    // Reset to the start of the day
    let components = calendar.dateComponents([.year, .month, .day], from: lastSunday)
    return calendar.date(from: components)!
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

