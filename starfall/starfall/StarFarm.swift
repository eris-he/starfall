//
//  starFarmAlgo.swift
//  starfall
//
//  Created by Eris He on 2/4/24.
//

import SwiftUI
import CoreData

struct StarFarm: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var stars: [Star] = []
    @State private var flowers: [Flower] = []

    var body: some View {
        Canvas { context, size in
            // Calculate the height of the canvas
            let canvasHeight = size.height
            CanvasDimensions.shared.height = size.height

            // Draw stars
            for star in stars {
                // Assuming Star.x and Star.y are CGFloats; if not, cast them
                let position = CGPoint(x: CGFloat(star.x), y: canvasHeight - CGFloat(star.y)) // Invert the y-coordinate
                if let starImage = UIImage(named: "starfield") {
                    let image = Image(uiImage: starImage)
                    let rect = CGRect(x: position.x - 15, y: position.y - 15, width: 30, height: 30) // Adjust width and height as needed
                    context.draw(image, in: rect)
                }
            }
            
            // Draw flowers
            // Sort flowers by height, ensuring larger flowers are drawn first
            let sortedFlowers = flowers.sorted {
                let height1: CGFloat = $0.plant_no % 2 == 0 ? 100 : 200
                let height2: CGFloat = $1.plant_no % 2 == 0 ? 100 : 200
                return height1 > height2
            }
            
            for flower in sortedFlowers {
                let positionX = CGFloat(flower.x)
                // Determine the target height based on plant_no
                let targetHeight: CGFloat = flower.plant_no % 2 == 0 ? 100 : 200
                
                // Construct the image name dynamically based on plant_no
                let imageName = "plant\(flower.plant_no)"
                if let flowerImage = UIImage(named: imageName) {
                    // Calculate the scaled width using the original image's aspect ratio
                    let originalAspectRatio = flowerImage.size.width / flowerImage.size.height
                    let scaledWidth = targetHeight * originalAspectRatio
                    
                    // Calculate the y-coordinate by subtracting from the canvas height
                    let positionY = canvasHeight - targetHeight
                    
                    // Create a rect that centers the image at positionX and sets y to the calculated positionY
                    let rect = CGRect(x: positionX - scaledWidth / 2, y: positionY, width: scaledWidth, height: targetHeight)
                    
                    // Draw the image within the specified rectangle
                    let image = Image(uiImage: flowerImage)
                    context.draw(image, in: rect)
                } else {
                    // Handle the case where the image does not exist
                    print("Image named \(imageName) not found.")
                }
            }
        }
        .background(GeometryReader { geometryProxy in
            Color.clear.onAppear {
                // Update the shared canvas dimensions with the actual size
                CanvasDimensions.shared.height = geometryProxy.size.height
            }
        })
        .onAppear {
            fetchMostRecentWeeklyStarFarm()
        }
    }
    
    private func fetchMostRecentWeeklyStarFarm() {
        let request: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeeklyStarFarm.week, ascending: false)]
        request.fetchLimit = 1
        
        DispatchQueue.main.async {
            do {
                let result = try self.viewContext.fetch(request)
                if let mostRecentWeeklyStarFarm = result.first {
                    self.stars = mostRecentWeeklyStarFarm.stars?.allObjects as? [Star] ?? []
                    self.flowers = mostRecentWeeklyStarFarm.flowers?.allObjects as? [Flower] ?? []
                }
            } catch {
                print("Failed to fetch the most recent WeeklyStarFarm: \(error)")
            }
        }
    }
}
