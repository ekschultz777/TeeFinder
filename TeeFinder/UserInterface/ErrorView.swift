//
//  ErrorView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    let action: (() -> Void)?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundStyle(AppColor.tertiaryForegroundColor)
                .frame(maxWidth: .infinity, maxHeight: 250)
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(AppColor.primaryForegroundColor)
                    .padding()
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                if let action {
                    Button(action: action) {
                        Text("OK")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
