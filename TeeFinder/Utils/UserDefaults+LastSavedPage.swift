//
//  UserDefaults+LastSavedPage.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/14/25.
//

import Foundation

extension UserDefaults {
    var lastSavedPage: Int? {
        get {
            UserDefaults.standard.value(forKey: "lastSavedPage") as? Int
        } set {
            UserDefaults.standard.setValue(newValue, forKey: "lastSavedPage")
        }
    }
}
