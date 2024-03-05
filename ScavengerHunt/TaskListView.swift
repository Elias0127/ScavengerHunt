//
//  ContentView.swift
//  ScavengerHunt
//
//  Created by Elias Woldie on 2/29/24.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
}


struct TaskListView: View {
    @State var tasks: [Task] = [
        Task(title: "Find a red flower", description: "Take a photo of a red flower in your neighborhood"),
        Task(title: "Capture a sunset", description: "Take a photo of a beautiful sunset"),
        Task(title: "Find a historic landmark", description: "Take a photo of a historic landmark in your city")
    ]
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            List($tasks) { $task in
                NavigationLink(destination: TaskDetailView(task: $task)) {
                    HStack {
                        if task.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.description)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Scavenger Hunt")
            .navigationBarItems(trailing: Button(action: {
            }) {
                Image(systemName: "plus")
            })
        }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}
