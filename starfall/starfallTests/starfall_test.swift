//
//  starfall_test.swift
//  starfallTests
//
//  Created by Eris He on 2/4/24.
//

import Foundation
import XCTest
import CoreData
@testable import starfall

class CoreDataTests: XCTestCase {
    var inMemoryCoreDataStack: InMemoryCoreDataStack!

    override func setUpWithError() throws {
        super.setUp()
        inMemoryCoreDataStack = InMemoryCoreDataStack.shared
    }

    override func tearDownWithError() throws {
        inMemoryCoreDataStack = nil
        super.tearDown()
    }

    func testFocusTimerCompletion() throws {
        let context = inMemoryCoreDataStack.viewContext
        
        // Simulate creating a FocusTimer entity for a 45-minute countdown
        let newTimer = FocusTimer(context: context)
        newTimer.timeCompleted = Date() // Mark the completion time as now
        newTimer.timeFocused = 45 // Set the focused time to 45 minutes
        
        // Optionally, simulate additional logic that would be triggered on completion
        // For example, creating associated entities or updating related data
        // This is where you'd include any logic that's executed in FocusView upon timer completion
        
        // Save the context to persist changes
        try context.save()
        
        // Fetch the FocusTimer entity to verify
        let fetchRequest: NSFetchRequest<FocusTimer> = FocusTimer.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1, "There should be one FocusTimer entity")
        guard let fetchedTimer = results.first else {
            XCTFail("No FocusTimer entity found")
            return
        }
        
        // Verify the attributes
        XCTAssertEqual(fetchedTimer.timeFocused, 45, "The focused time should be 45 minutes")
        // Add any additional assertions here as needed
        
        // If you have logic that calculates something based on `timeFocused`,
        // you can assert those outcomes here as well
    }
}
