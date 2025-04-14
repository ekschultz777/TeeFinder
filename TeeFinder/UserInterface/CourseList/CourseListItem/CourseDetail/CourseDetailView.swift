//
//  CourseDetailView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation
import SwiftUI

struct CourseDetailView: View {
    @StateObject var viewModel: CourseDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.clubName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    Text(viewModel.courseName)
                        .font(.title2)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    if let address = viewModel.address {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text("\(address)")
                        }
                        .font(.subheadline)
                        .foregroundColor(AppColor.secondaryForegroundColor)
                    }
                }

                Divider()

                // Tees Section
                VStack(alignment: .leading, spacing: 16) {
                    if let maleTees = viewModel.tees?.male, !maleTees.isEmpty {
                        Text("Men's Tees")
                            .font(.headline)
                            .foregroundColor(AppColor.secondaryForegroundColor)

                        ForEach(Array(maleTees.enumerated()), id: \.offset) { index, tee in
                            let viewModel = TeeDetailViewModel(model: tee)
                            TeeDetailView(viewModel: viewModel)
                        }
                    }

                    if let femaleTees = viewModel.tees?.female, !femaleTees.isEmpty {
                        Text("Women's Tees")
                            .font(.headline)
                            .foregroundColor(AppColor.secondaryForegroundColor)
                            .padding(.top)

                        ForEach(Array(femaleTees.enumerated()), id: \.offset) { index, tee in
                            let viewModel = TeeDetailViewModel(model: tee)
                            TeeDetailView(viewModel: viewModel)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background {
            Color.black
                .ignoresSafeArea()
        }
    }
}
