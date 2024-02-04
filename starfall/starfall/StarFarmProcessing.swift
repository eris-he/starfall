//
//  StarFarmProcessing.swift
//  starfall
//
//  Created by Eris He on 2/4/24.
//

import Foundation
import CoreData

extension Date {
    func nearestPreviousSunday() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
}

func ensureWeeklyStarFarmExists(for date: Date, in context: NSManagedObjectContext) {
    let sunday = date.nearestPreviousSunday()
    
    let fetchRequest: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "week == %@", sunday as CVarArg)
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            // No WeeklyStarFarm exists for this week; create a new one
            let newWeeklyStarFarm = WeeklyStarFarm(context: context)
            newWeeklyStarFarm.week = sunday
            
            try context.save()
        }
        // If a WeeklyStarFarm already exists, no action is needed
    } catch {
        print("Failed to fetch or create WeeklyStarFarm: \(error)")
    }
}
