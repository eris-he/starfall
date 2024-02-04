#Preview {
    OverviewView()
}
//
//  OverviewView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct OverviewView: View {
    var body: some View {
        
        ZStack {
            Color("bg-color")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                HStack {
                    Image("star-2") // Replace with the actual name of your first image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                            
                    Image("star-2") // Replace with the actual name of your second image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(y: -20)
                            
                    Image("star-2") // Replace with the actual name of your third image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                            
                        // Add more images as needed
                }
                
                // Star garden area with the separate "Focus" button
                Text("Completed Tasks: 5")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size:28))
                    
                
                Text("Scheduled Tasks: 10")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size:28))
                
                ZStack {
                    Image("sun") // Replace with the actual name of your first image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                    
                    Text("50%")
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 3)
                        .bold()
                        .font(.custom("Futura-Medium", size: 64))
                }
                
                Text("Productivity")
                    .foregroundColor(.white)
                    .font(.custom("Futura-Medium", size:48))
            }
        }
    }
}
