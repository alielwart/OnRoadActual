//
//  File.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/3/22.
//

import Foundation

struct SettingsPage: Hashable, Codable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
}
