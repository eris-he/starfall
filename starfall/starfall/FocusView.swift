//
//  FocusView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct FocusView: View {
    @State private var timerIsActive = false
    @State private var showAlert = false // For stopping confirmation
    let initialTime = 60 * 60 // 1 hour in seconds
    @State private var selectedTime: Int
    
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
                
                CircularTimerView(selectedTime: $selectedTime, timerIsActive: $timerIsActive)
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
            guard timerIsActive, selectedTime > 0 else { return }
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
