#Preview {
    LoadingView()
}
//
//  LoadingView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct LoadingView: View {
    @State private var rocketOffset = CGSize(width: -600, height: 1250)
    
    var body: some View {
        ZStack {
            Color("bg-color")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                            Spacer()
                            
                            HStack {
                                Image("rocket") // Replace with the actual name of your first image asset
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 500, height: 500) // Adjust the size as needed
                                    .offset(rocketOffset)
                                    .animation(
                                        Animation.easeInOut(duration: 4) // Adjust the duration as needed
                                            .repeatForever(autoreverses: false)
                                    )
                            }
                        }
                    }
                    .onAppear {
                        // Set the final position where the rocket should end up
                        rocketOffset = CGSize(width: 400, height: -300)
                    }
        
    }
}
