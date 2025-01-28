//
//  SparklingShinyButton.swift
//  AwesomeSwiftUI
//
//  Created by Rahul P John on 28/01/25.
//

import SwiftUI

struct SparklingShinyButton: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            ReactiveControl()
                .frame(width: 240.0, height: 100.0)
        }
    }
}
