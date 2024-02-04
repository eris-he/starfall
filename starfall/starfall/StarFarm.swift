//
//  starFarmAlgo.swift
//  starfall
//
//  Created by Eris He on 2/4/24.
//

import Foundation
import SwiftUI
import CoreData
import UIKit

struct StarFarm: View {
    
    var body: some View {
        Canvas { context, size in
            // Define the positions where you want to place your images
            let starPositions = [CGPoint(x: 100, y: 100), CGPoint(x: 200, y: 200)] // Example positions for stars
            let flowerPositions = [CGPoint(x: 150, y: 150), CGPoint(x: 250, y: 250)] // Example positions for flowers
            
            // Draw stars at the specified positions
            for position in starPositions {
                if let uiImage = UIImage(named: "starfield") {
                    let image = Image(uiImage: uiImage) // Convert UIImage to SwiftUI Image
                    // Create a CGRect for the image that centers it on the position with the specified size
                    let rect = CGRect(x: position.x - 25, y: position.y - 25, width: 50, height: 50)
                    // Draw the image within the specified rectangle
                    context.draw(image, in: rect)
                }
            }
            
            // Draw flowers at the specified positions
//            for position in flowerPositions {
//                if let flowerImage = UIImage(named: "flower") { // Replace "flower" with your flower image asset name
//                    context.draw(flowerImage, in: CGRect(origin: position, size: CGSize(width: 50, height: 50))) // Adjust size as needed
//                }
//            }
        }
    }
}


struct StarFarm_Previews: PreviewProvider {
    static var previews: some View {
        StarFarm()
    }
}
