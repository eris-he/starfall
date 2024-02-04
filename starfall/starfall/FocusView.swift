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
            }
        }
    }
}

struct CircularTimerView: View {
    
    let timerIncrements = 15 * 60
    let maxTime = 240 * 60
    @Binding var selectedTime: Int
    @Binding var timerIsActive: Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Timer to tick every minute
    var managedObjectContext: NSManagedObjectContext
    
    var body: some View {
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
    
    func onComplete() {
        let focusTimer = FocusTimer(context: managedObjectContext)
        focusTimer.timeCompleted = Date()
        focusTimer.timeFocused = Int16(selectedTime) / 60 // Convert seconds to minutes
        
        let flower = Flower(context: managedObjectContext)
        flower.isVisible = false
        // Assign `plant_no` and `x` as needed
        // For simplicity, let's assume sequential planting and a fixed `x` position
        let isBigPlant = (focusTimer.timeFocused > 90) // More than 90 minutes for a big plant
        if isBigPlant {
            // Choose an odd number between 1 and 20 for big plants
            flower.plant_no = Int16.random(in: 1...10) * 2 - 1
        } else {
            // Choose an even number between 1 and 20 for small plants
            flower.plant_no = Int16.random(in: 1...10) * 2
        }
        
        assignXPosition(for: flower, in: managedObjectContext, isBigPlant: isBigPlant)

        // Link the FocusTimer and Flower
        focusTimer.flower = flower
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save FocusTimer and Flower: \(error)")
        }
    }
    
    func assignXPosition(for flower: Flower, in context: NSManagedObjectContext, isBigPlant: Bool, canvasWidth: Int = 300) {
        let fetchRequest: NSFetchRequest<Flower> = Flower.fetchRequest()
        // If big plants can overlap any, but small cannot overlap another small, consider fetching only small plants if the current one is small.
        if !isBigPlant {
            fetchRequest.predicate = NSPredicate(format: "plant_no %% 2 == 0") // Fetch only small plants
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "x", ascending: true)]
        
        do {
            let existingFlowers = try context.fetch(fetchRequest)
            let existingXPositions = existingFlowers.map { Int($0.x) }
            
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

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
