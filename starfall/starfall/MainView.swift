//
//  ContentView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let persistenceController = PersistenceController.shared
    
    init() {
        ensureWeeklyStarFarmExists(for: Date(), in: persistenceController.container.viewContext)
    }
    
    let buttons = [
        ("Tasks", "planet-1"),
        ("Calendar", "planet-2"),
        ("Notes", "planet-3"),
        ("Health", "planet-4"),
        ("Overview", "planet-5")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("bg-color")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Star garden area with the separate "Focus" button
                    starGarden()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                    
//                    Divider()
//                        .background(Color.white)
//                        .padding(.horizontal)
                    
                    // Grid layout for the rest of the buttons
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(buttons, id: \.0) { button in
                            navigationButton(label: button.0, imageName: button.1)
                        }
                    }
                    .padding(.horizontal)
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
        NavigationLink(destination: destinationView(for: label)) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .opacity(0.7)
                Text(label)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 3)
                    .bold()
                    .font(.custom("Futura-Medium", size: 24))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("bg-color"))
            .cornerRadius(10)
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
        case "Overview":
            return AnyView(OverviewView())
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

