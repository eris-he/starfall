//
//  FocusView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import CoreData

struct FocusView: View {
    @State private var timerIsActive = false
    @State private var showAlert = false // For stopping confirmation
    let initialTime = 60 * 60 // 1 hour in seconds
    @State private var selectedTime: Int
    @Environment(\.managedObjectContext) var managedObjectContext

    
    init() {
        _selectedTime = State(initialValue: initialTime)
    }
    
    var body: some View {
        ZStack {
            Color("bg-color").ignoresSafeArea()
            
            VStack {
                Text("Let's focus...")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size: 42))
                
                Spacer()
                
                CircularTimerView(selectedTime: $selectedTime, timerIsActive: $timerIsActive, managedObjectContext: managedObjectContext)
                    .padding()
                
                Button(action: {
                    if timerIsActive {
                        showAlert = true // Show alert to confirm stopping
                    } else {
                        selectedTime = selectedTime // Reset time for a new session
                        timerIsActive = true
                    }
                }) {
                    Text(timerIsActive ? "Stop" : "Start")
                        .foregroundColor(.white)
                        .font(.custom("Futura-Medium", size: 24))
                        .padding()
                        .background(timerIsActive ? Color.red : Color.green)
                        .cornerRadius(20)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Are you sure?"),
                        message: Text("Your progress will not be saved."),
                        primaryButton: .destructive(Text("Stop")) {
                            timerIsActive = false // Stop and reset timer
                            selectedTime = initialTime
                        },
                        secondaryButton: .cancel { timerIsActive = true }
                    )
                }
                
                Spacer()
                
                //==================== TESTING BLOCK FOR TESTING ONLY ====================
                Text("Testing Buttons!")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size:24))
                Group {
                    let source = CircularTimerView(selectedTime: $selectedTime, timerIsActive: $timerIsActive, managedObjectContext: managedObjectContext)
                    Button("Add 15 Minute Timer") {
                        source.testComplete(focusMinutes: 15)
                    }
                    .background(Color.black)
                    .cornerRadius(8)
                    
                    Button("Add 45 Minute Timer") {
                        source.testComplete(focusMinutes: 45)
                    }
                    .background(Color.black)
                    .cornerRadius(8)
                    
                    Button("Add 90 Minute Timer") {
                        source.testComplete(focusMinutes: 90)
                    }
                    .background(Color.black)
                    .cornerRadius(8)
                    
                    Button("Add 120 Minute Timer") {
                        source.testComplete(focusMinutes: 120)
                    }
                    .background(Color.black)
                    .cornerRadius(8)
                }
                .foregroundColor(.white)
                .font(.custom("Futura-Medium", size: 18))
                
                //==================== TESTING BLOCK FOR TESTING ONLY ====================
                // EXTRACT FROM VSTACK WHEN DONE TESTING
                
            }
        }
    }
}

struct CircularTimerView: View {
    
    let timerIncrements = 15 * 60
    let maxTime = 180 * 60
    @Binding var selectedTime: Int
    @Binding var timerIsActive: Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Timer to tick every second
    var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .foregroundColor(Color.gray.opacity(0.2))
                
                Circle()
                    .trim(from: 0, to: CGFloat(selectedTime) / CGFloat(maxTime))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: selectedTime)
                
                Text(timeFormatted(selectedTime))
                    .font(.custom("Futura-Medium", size: 32))
                    .foregroundColor(.white)
                
            }
            .frame(width: 300, height: 300)
            .onReceive(timer) { _ in
                guard timerIsActive, selectedTime > 0 else {
                    if selectedTime == 0 {
                        onComplete()
                    }
                    return
                }
                selectedTime -= 1
            }
            .gesture(
                timerIsActive ? nil :
                DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        self.selectedTime = timeForGesture(value: value)
                    })
            )
            

        }

    }
    
    
    //==================== TESTING BLOCK FOR TESTING ONLY ====================

    func testComplete(focusMinutes: Int) {
        let focusTimer = FocusTimer(context: managedObjectContext)
        focusTimer.timeCompleted = Date()
        focusTimer.timeFocused = Int16(focusMinutes) // Directly set in minutes
        
        let weeklyStarFarm = fetchOrCreateWeeklyStarFarm()
        let flower = Flower(context: managedObjectContext)
        flower.isVisible = false
        
        // Determine if the plant is big based on the focus duration
        let isBigPlant = focusMinutes > 60 // More than 60 minutes for a big plant
        flower.plant_no = isBigPlant ? Int16.random(in: 1...10) * 2 - 1 : Int16.random(in: 1...10) * 2
        assignXPosition(for: flower, in: managedObjectContext, isBigPlant: isBigPlant)
        
        // Link the FocusTimer and Flower
        focusTimer.flower = flower
        weeklyStarFarm.addToFlowers(flower)
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save FocusTimer and Flower: \(error)")
        }
    }

    //==================== TESTING BLOCK FOR TESTING ONLY ====================
    
    
    func onComplete() {
        let focusTimer = FocusTimer(context: managedObjectContext)
        focusTimer.timeCompleted = Date()
        focusTimer.timeFocused = Int16(selectedTime) / 60 // Convert seconds to minutes
        
        let weeklyStarFarm = fetchOrCreateWeeklyStarFarm()
        let flower = Flower(context: managedObjectContext)
        flower.isVisible = false
        // Assign `plant_no` and `x` as needed
        // For simplicity, let's assume sequential planting and a fixed `x` position
        let isBigPlant = (focusTimer.timeFocused > 90) // More than 90 minutes for a big plant
//        if isBigPlant {
//            // Choose an odd number between 1 and 20 for big plants
//            flower.plant_no = Int16.random(in: 1...10) * 2 - 1
//        } else {
//            // Choose an even number between 1 and 20 for small plants
//            flower.plant_no = Int16.random(in: 1...10) * 2
//        }
//        
//        assignXPosition(for: flower, in: managedObjectContext, isBigPlant: isBigPlant)
        
        flower.plant_no = isBigPlant ? Int16.random(in: 1...10) * 2 - 1 : Int16.random(in: 1...10) * 2
        assignXPosition(for: flower, in: managedObjectContext, isBigPlant: isBigPlant)

        // Link the FocusTimer and Flower
        focusTimer.flower = flower
        weeklyStarFarm.addToFlowers(flower) // Assuming a relationship exists
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save FocusTimer and Flower: \(error)")
        }
    }
    
    func assignXPosition(for flower: Flower, in context: NSManagedObjectContext, isBigPlant: Bool, canvasWidth: Int = Int(CanvasDimensions.shared.width)) {
        let fetchRequest: NSFetchRequest<Flower> = Flower.fetchRequest()
        // If big plants can overlap any, but small cannot overlap another small, consider fetching only small plants if the current one is small.
//        if !isBigPlant {
//            fetchRequest.predicate = NSPredicate(format: "plant_no % 2 == 0") // Fetch only small plants
//        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "x", ascending: true)]
        
        do {
            let existingFlowers = try context.fetch(fetchRequest)
            let filteredFlowers = isBigPlant ? existingFlowers : existingFlowers.filter { Int($0.plant_no) % 2 == 0 }
            let existingXPositions = filteredFlowers.map { Int($0.x) }

            // Define spacing and size based on plant types for collision detection
            let plantSize = isBigPlant ? 50 : 30 // Assuming size represents potential collision space
            
            var randomX: Int
            var collisionDetected: Bool
            
            repeat {
                // Generate a random position within the canvas width, adjusted for plant size
                randomX = Int.random(in: 0..<(canvasWidth - plantSize))
                collisionDetected = false
                
                if !isBigPlant {
                    // Check for collision only if it's a small plant
                    for existingX in existingXPositions {
                        // Check if the randomly selected position collides with an existing small plant
                        if abs(existingX - randomX) < plantSize {
                            collisionDetected = true
                            break
                        }
                    }
                }
            } while collisionDetected // Continue until a non-colliding position is found
            
            // Assign the calculated position
            flower.x = Int16(randomX)
            
        } catch {
            print("Failed to fetch existing flowers: \(error)")
        }
    }
    
    func timeForGesture(value: DragGesture.Value) -> Int {
        let vector = CGVector(dx: value.location.x - 150, dy: value.location.y - 150)
        let angle = atan2(vector.dx, -vector.dy)
        var degree = angle * 180 / Double.pi
        degree = degree < 0 ? 360 + degree : degree
        
        let time = Int(degree / 360 * CGFloat(maxTime))
        return time - (time % timerIncrements)
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let hours: Int = totalSeconds / 3600
        let minutes: Int = (totalSeconds % 3600) / 60
        let seconds: Int = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)
    }
}

extension CircularTimerView {
    func fetchOrCreateWeeklyStarFarm() -> WeeklyStarFarm {
        let context = managedObjectContext
        let calendar = Calendar.current
        let now = Date()
        guard let mostRecentSunday = now.startOfWeek(using: calendar) else { fatalError("Could not find the start of the week") }
        
        let request: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
        request.predicate = NSPredicate(format: "week == %@", mostRecentSunday as NSDate)
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            if let existingFarm = results.first {
                return existingFarm
            }
        } catch {
            print("Error fetching WeeklyStarFarm: \(error)")
        }

        // If there's no WeeklyStarFarm for the most recent Sunday, create a new one
        let newFarm = WeeklyStarFarm(context: context)
        newFarm.week = mostRecentSunday
        return newFarm
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
