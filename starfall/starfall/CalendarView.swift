//
//  CalendarView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @State private var events: [EKEvent] = []
    let eventStore = EKEventStore()

    var body: some View {
        VStack {
            Text("Calendar Events")
                .font(.title)
                .padding()
            
            List(events, id: \.eventIdentifier) { event in
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text("\(event.startDate) - \(event.endDate)")
                        .font(.subheadline)
                }
            }
        }
        .onAppear {
            requestCalendarAccess()
        }
    }

    /*
     This function requests access from the calendar and takes the user to
     the settings app if they do not allow the app access to the calendar app.
     The open settings function is commented out temporarily
     */
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                fetchCalendarEvents()
            } else {
                //openSettings()
            }
        }
    }

    /*
     * This function finds the events for the upcoming week
     */
    private func fetchCalendarEvents() {
        let calendars = eventStore.calendars(for: .event)
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(60 * 60 * 24 * 7) // Fetch events for the next week

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)

        events = eventStore.events(matching: predicate)
    }
    
    /*
     This function opens the settings app. Will need to add the Starfall app to the URL below
     */
    private func openSettings() {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
        DispatchQueue.main.async{
            UIApplication.shared.open(settingsURL)
        }
        }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
