//
//  CalendarViewController.swift
//  starfall
//
//  Created by Auburn University Student on 2/3/24.
//

import UIKit
import CalendarKit
import EventKit

class CalendarViewController: DayViewController {
    let store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        requestAccess()
    }
    
    func requestAccess() {
        store.requestAccess(to: .event) { success, error in
        }
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventKitEvents = store.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map { ekEvent -> Event in
            let ckEvent = Event()
            ckEvent.dateInterval.start = ekEvent.startDate
            ckEvent.dateInterval.end = ekEvent.endDate
            ckEvent.isAllDay = ekEvent.isAllDay
            ckEvent.text = ekEvent.title
            if let eventColor = ekEvent.calendar.cgColor {
                ckEvent.color = UIColor(cgColor: eventColor)
            }
            return ckEvent
        }
        return calendarKitEvents
    }
}
