//
//  FocusView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI
import RealityKit


struct FocusView: View {
    
    var body: some View {
        ZStack {
            Color("bg-color")
                .ignoresSafeArea()
            
            VStack {
                Text("Let's focus...")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size: 24))
                
                let orbit = OrbitAnimation(name: "orbit",
                    duration: 10.0,
                    axis: SIMD3<Float>(x: 1.0, y: 0.0, z: 0.0),
                    startTransform: Transform(scale: simd_float3(10,10,10),
                    rotation: simd_quatf(ix: 10, iy: 20, iz: 20, r: 100),
                    translation: simd_float3(11, 2, 3)),
                    spinClockwise: false,
                    orientToPath: true,
                    rotationCount: 100.0,
                    bindTarget: nil)


                // Create an animation clip for just the second half of the orbit.
                let trimmed = orbit.trimmed(start: 5.0, end: 10.0)
            }
        }
    }
}

struct FocusView_Previews: PreviewProvider {
    static var previews: some View {
        FocusView()
    }
}
