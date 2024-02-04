//
//  Globals.swift
//  starfall
//
//  Created by Eris He on 2/4/24.
//

import Foundation
import SwiftUI

class CanvasDimensions: ObservableObject {
    static let shared = CanvasDimensions()
    @Published var width: CGFloat = UIScreen.main.bounds.width
    @Published var height: CGFloat = .zero
}
