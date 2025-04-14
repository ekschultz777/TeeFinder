//
//  CourseListItemView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation
import SwiftUI

struct CourseListItemView: View {
    @StateObject var viewModel: CourseListItemViewModel
        
    var body: some View {
        NavigationLink(destination: {
            CourseDetailView(viewModel: CourseDetailViewModel(viewModel.model))
        }, label: {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: "flag.circle.fill")
                    .resizable()
                    .frame(maxWidth: 30, maxHeight: 30)
                    .foregroundColor(AppColor.primaryForegroundColor)
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.clubName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    Text(viewModel.courseName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColor.secondaryForegroundColor)
                    if let address = viewModel.address {
                        Text(address)
                        .font(.subheadline)
                        .foregroundColor(AppColor.secondaryForegroundColor)
                    }
                    if let tees = viewModel.tees, let commonTee = tees.commonTee() {
                        HStack(spacing: 8) {
                            if let rating = commonTee.courseRating {
                                Text(String(format: "Rating: %.1f", rating))
                                    .font(.footnote)
                                    .foregroundColor(AppColor.secondaryForegroundColor)
                            }
                            if let slope = commonTee.slopeRating {
                                Text("Slope: \(slope)")
                                    .font(.footnote)
                                    .foregroundColor(AppColor.secondaryForegroundColor)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.vertical)
        })
        .listRowBackground(AppColor.secondaryBackgroundColor)
    }
}
