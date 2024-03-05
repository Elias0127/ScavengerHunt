//
//  TaskDetailView.swift
//  ScavengerHunt
//
//  Created by Elias Woldie on 2/29/24.
//

import SwiftUI
import PhotosUI
import MapKit
import CoreImage
import ImageIO


struct TaskDetailView: View {
    @Binding var task: Task
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            Text(task.title)
                .font(.largeTitle)
            Text(task.description)
                .font(.body)
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Button("Attach Photo") {
                isPickerPresented = true
            }
            if let location = task.location {
                Map(coordinateRegion: .constant(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))), annotationItems: [location]) { loc in
                    MapAnnotation(coordinate: loc.coordinate) {
                        VStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .frame(height: 200)
            }



        }
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImage: $selectedImage, task: $task)
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var task: Task

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self, let image = image as? UIImage, error == nil else { return }
                    
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                        self.parent.task.isCompleted = true
                        self.extractLocation(from: provider)
                    }
                }
            }
        }


        private func extractLocation(from provider: NSItemProvider) {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                let ciImage = CIImage(data: data)
                let metadata = ciImage?.properties
                
                if let gpsData = metadata?[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
                    self.processGPSData(gpsData)
                }
            }
        }

        private func processGPSData(_ gpsData: [String: Any]) {
            if let latitudeNumber = gpsData[kCGImagePropertyGPSLatitude as String] as? NSNumber,
               let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
               let longitudeNumber = gpsData[kCGImagePropertyGPSLongitude as String] as? NSNumber,
               let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String {
               
                var latitude = latitudeNumber.doubleValue
                var longitude = longitudeNumber.doubleValue
                
                // Latitude South 
                if latitudeRef == "S" {
                    latitude = -latitude
                }
                
                // Longitude West
                if longitudeRef == "W" {
                    longitude = -longitude
                }
                
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                DispatchQueue.main.async {
                    self.parent.task.location = Location(coordinate: location)
                }
            }
        }


    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: .constant(Task(title: "Test Task", description: "This is a test task", isCompleted: false)))
    }
}

