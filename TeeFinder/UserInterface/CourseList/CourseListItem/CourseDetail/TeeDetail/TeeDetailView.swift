//
//  TeeDetailView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation
import SwiftUI

struct TeeDetailView: View {
    @StateObject var viewModel: TeeDetailViewModel
    @State private var showHoles = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.teeName ?? "Unknown")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.primaryForegroundColor)

            HStack(spacing: 16) {
                if let rating = viewModel.courseRating {
                    Label("Rating: \(String(format: "%.1f", rating))", systemImage: "star.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let slope = viewModel.slopeRating {
                    Label("Slope: \(slope)", systemImage: "triangle.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let par = viewModel.parTotal {
                    Label("Par: \(par)", systemImage: "flag.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let yards = viewModel.totalYards {
                    Label("Yards: \(yards)", systemImage: "ruler")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }
            }
            .font(.caption)

            if let holes = viewModel.holes, !holes.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut) {
                        showHoles.toggle()
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: showHoles ? "chevron.up" : "chevron.down")
                            .transaction { transaction in
                                // Disable this button's animation
                                transaction.animation = nil
                            }
                        Spacer()
                    }
                    .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if showHoles {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(holes.indices, id: \.self) { i in
                            let hole = holes[i]
                            HStack {
                                Text("Hole \(i + 1):")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                if let par = hole.par {
                                    Text("Par: \(par)")
                                }
                                if let yardage = hole.yardage {
                                    Text("Yards: \(yardage)")
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(AppColor.secondaryForegroundColor)
                            if i != holes.count - 1  {
                                Divider()
                                    .background(AppColor.tertiaryForegroundColor)
                            }
                        }
                        .transition(.opacity.combined(with: .slide))
                    }
                }
            }
        }
        .padding()
        .background(AppColor.secondaryBackgroundColor)
        .cornerRadius(10)
    }
}
