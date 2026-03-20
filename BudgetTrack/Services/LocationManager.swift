//
//  LocationManager.swift
//  BudgetTrack
//
//  Created by Baran on 20.03.2026.
//

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    private let manager = CLLocationManager()
    
    @Published var userLocation : CLLocationCoordinate2D?
    @Published var locationName : String = ""
    @Published var authorizationStatus : CLAuthorizationStatus = .notDetermined
    
    override init(){
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation(){
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        fetchLocationName(from: location)
    }
    
    func fetchLocationName(from location: CLLocation){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let placemark = placemarks?.first {
                let name = [
                    placemark.name,
                    placemark.locality
                ].compactMap {$0}.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.locationName = name
                }
                
            }
               
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Konum hatası: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    
}
