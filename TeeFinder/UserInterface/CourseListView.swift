//
//  CourseListView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI
import CoreData

typealias CourseListViewModel = ContentViewModel

struct CourseListView: View {
    @ObservedObject var viewModel: CourseListViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { course in
                CourseListItemView(viewModel: viewModel,
                                   course: course,
                                   clubName: course.clubName,
                                   location: course.location.address,
                                   tees: course.tees)
            }
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listRowSpacing(8)
    }
}

struct CourseListItemView: View {
    typealias CourseListItemViewModel = CourseListViewModel
    let viewModel: CourseListItemViewModel
    let course: CourseModel
    let clubName: String
    let location: String?
    let tees: CourseModel.Tees?
        
    var body: some View {
        NavigationLink(destination: {
            CourseDetailView(course: course)
        }, label: {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: "flag.circle.fill")
                    .resizable()
                    .frame(maxWidth: 30, maxHeight: 30)
                    .foregroundColor(AppColor.primaryForegroundColor)
                VStack(alignment: .leading, spacing: 8) {
                    Text(clubName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    Text(course.courseName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColor.secondaryForegroundColor)
                    if let location {
                        Text(location)
                        .font(.subheadline)
                        .foregroundColor(AppColor.secondaryForegroundColor)
                    }
                    if let tees, let commonTee = tees.commonTee() {
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


struct CourseDetailView: View {
    let course: CourseModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.clubName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    Text(course.courseName)
                        .font(.title2)
                        .foregroundColor(AppColor.primaryForegroundColor)
                    if let address = course.location.address {
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
                    if let maleTees = course.tees?.male, !maleTees.isEmpty {
                        Text("Men's Tees")
                            .font(.headline)
                            .foregroundColor(AppColor.secondaryForegroundColor)

                        ForEach(Array(maleTees.enumerated()), id: \.offset) { index, tee in
                            TeeDetailView(tee: tee)
                        }
                    }

                    if let femaleTees = course.tees?.female, !femaleTees.isEmpty {
                        Text("Women's Tees")
                            .font(.headline)
                            .foregroundColor(AppColor.secondaryForegroundColor)
                            .padding(.top)

                        ForEach(Array(femaleTees.enumerated()), id: \.offset) { index, tee in
                            TeeDetailView(tee: tee)
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
//    func openMapForPlace() {
//
//        let lat1 : NSString = self.venueLat
//        let lng1 : NSString = self.venueLng
//
//        let latitude:CLLocationDegrees =  lat1.doubleValue
//        let longitude:CLLocationDegrees =  lng1.doubleValue
//
//        let regionDistance:CLLocationDistance = 10000
//        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
//        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
//        let options = [
//            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
//            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
//        ]
//        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//        let mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = "\(self.venueName)"
//        mapItem.openInMapsWithLaunchOptions(options)
//    }
}

struct TeeDetailView: View {
    let tee: CourseModel.Tees.Tee
    @State private var showHoles = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tee.teeName ?? "Unknown")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppColor.primaryForegroundColor)

            HStack(spacing: 16) {
                if let rating = tee.courseRating {
                    Label("Rating: \(String(format: "%.1f", rating))", systemImage: "star.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let slope = tee.slopeRating {
                    Label("Slope: \(slope)", systemImage: "triangle.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let par = tee.parTotal {
                    Label("Par: \(par)", systemImage: "flag.fill")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }

                if let yards = tee.totalYards {
                    Label("Yards: \(yards)", systemImage: "ruler")
                        .foregroundStyle(AppColor.primaryForegroundColor)
                }
            }
            .font(.caption)

            if let holes = tee.holes, !holes.isEmpty {
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

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

