#Preview {
    CalendarView()
}
//
//  CalendarView.swift
//  starfall
//
//  Created by Eris He on 2/3/24.
//

import SwiftUI

struct CalendarViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return CalendarViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Update the view controller if needed
    }
}

struct CalendarView: View {
    var body: some View {
        VStack{
            CalendarViewControllerWrapper()
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.indigo,
                           // 2
                           for: .navigationBar)
    }
}


