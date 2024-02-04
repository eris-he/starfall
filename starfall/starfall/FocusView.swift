//
//  FocusView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct FocusView: View {
    
    var body: some View {
        ZStack {
            Color("bg-color")
                .ignoresSafeArea()
            
            VStack {
                Text("Let's focus...")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size: 24))
                Spacer()
                CircularTimerView()
                Spacer()
            }
        }
    }
}

struct CircularTimerView: View {
    let timerIncrements = 15
    let maxTime = 240
    @State private var vectorVal: String = ""
    @State private var selectedTime: Int = 0
    @State private var angleStr: String = ""
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
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
            
            Text("\(selectedTime) min")
                .font(.title)
                .foregroundColor(.white)
            
        }
        .frame(width: 300, height: 300)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    self.selectedTime = timeForGesture(value: value)
                })
        )
    }
    
    func timeForGesture(value: DragGesture.Value) -> Int {
        let vector = CGVector(dx: value.location.x - 150, dy: value.location.y - 150)
        var angle = atan2(vector.dx, -vector.dy)
        var degree = angle * 180 / Double.pi
        degree = degree < 0 ? 360 + degree : degree
        
        let time = Int(degree / 360 * CGFloat(maxTime))
        return time - (time % timerIncrements)
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
