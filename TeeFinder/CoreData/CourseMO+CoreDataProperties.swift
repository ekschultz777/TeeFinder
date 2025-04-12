//
//  CourseMO+CoreDataProperties.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//
//

import Foundation
import CoreData


extension CourseMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseMO> {
        return NSFetchRequest<CourseMO>(entityName: "CourseMO")
    }

    // TODO: Remove data and add properties
    @NSManaged public var data: Data
    @NSManaged public var id: Int32
}

extension CourseMO : Identifiable {

}
