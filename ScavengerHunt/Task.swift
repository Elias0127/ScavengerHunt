//
//  Task.swift
//  ScavengerHunt
//
//  Created by Elias Woldie on 2/29/24.
//

import CoreLocation

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool = false
    var photoURL: URL? = nil
    var location: Location?
}

struct Location: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

