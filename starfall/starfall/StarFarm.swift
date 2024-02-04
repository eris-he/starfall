//
//  starFarmAlgo.swift
//  starfall
//
//  Created by Eris He on 2/4/24.
//

import SwiftUI
import CoreData

struct StarFarm: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var stars: [Star] = []
    @State private var flowers: [Flower] = []
    

    var body: some View {
        Canvas { context, size in
            // Draw stars
            for star in stars {
                // Assuming Star.x and Star.y are CGFloats; if not, cast them
                let position = CGPoint(x: CGFloat(star.x), y: CGFloat(star.y))
                if let starImage = UIImage(named: "starfield") {
                    let image = Image(uiImage: starImage)
                    let rect = CGRect(x: position.x - 25, y: position.y - 25, width: 50, height: 50)
                    context.draw(image, in: rect)
                }
            }
            
            // Draw flowers
            for flower in flowers {
                let positionX = CGFloat(flower.x)
                // Determine the size based on plant_no
                let size: CGSize = flower.plant_no % 2 == 0 ? CGSize(width: 100, height: 100) : CGSize(width: 200, height: 200)
                let rect = CGRect(x: positionX - size.width / 2, y: 0, width: size.width, height: size.height)

                // Construct the image name dynamically based on plant_no
                let imageName = "plant\(flower.plant_no)"
                if let flowerImage = UIImage(named: imageName) {
                    let image = Image(uiImage: flowerImage)
                    context.draw(image, in: rect)
                } else {
                    // Optional: Handle the case where the image does not exist
                    print("Image named \(imageName) not found.")
                }
            }
        }
        .onAppear {
            fetchMostRecentWeeklyStarFarm()
        }
    }
    
    private func fetchMostRecentWeeklyStarFarm() {
        let request: NSFetchRequest<WeeklyStarFarm> = WeeklyStarFarm.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeeklyStarFarm.week, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let result = try viewContext.fetch(request)
            if let mostRecentWeeklyStarFarm = result.first {
                // Assuming 'stars' and 'flowers' are the relationship names in your Core Data model
                self.stars = mostRecentWeeklyStarFarm.stars?.allObjects as? [Star] ?? []
                self.flowers = mostRecentWeeklyStarFarm.flowers?.allObjects as? [Flower] ?? []
            }
        } catch {
            print("Failed to fetch the most recent WeeklyStarFarm: \(error)")
        }
    }
}
