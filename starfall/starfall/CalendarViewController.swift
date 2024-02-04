//
//  CalendarViewController.swift
//  starfall
//
//  Created by Auburn University Student on 2/3/24.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

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
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_ :)), name: .EKEventStoreChanged, object: nil)
    }
    
    @objc func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventKitEvents = store.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
        return calendarKitEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        
        let ekEvent = ckEvent.ekEvent
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }
}
