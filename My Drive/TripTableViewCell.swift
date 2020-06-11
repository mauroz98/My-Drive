//
//  TripTableViewCell.swift
//  My Drive
//
//  Created by Michele Navolio on 22/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import MapKit

class TripTableViewCell: UITableViewCell {
    
    
    @IBOutlet var giornoLabel: UILabel!
    @IBOutlet var meseLabel: UILabel!
    @IBOutlet var distanzaPercorsa: UILabel!
    @IBOutlet var timeTravel: UILabel!
    @IBOutlet var startView: UIView!
    @IBOutlet var finishView: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var mapButton: UIButton!
    
    
    
    @IBAction func mapButtonPress(_ sender: UIButton) {
        
 print("bottone della cella premuto")
//            // Declaration of coordinates for map
//            let mapLatitude : CLLocationDegrees = trip.parkLatitude
//            let mapLongitude : CLLocationDegrees = trip.parkLongitude
//            // Set distance of view for map
//            let regionDistance : CLLocationDistance = 5000
//
//
//            let coordinates = CLLocationCoordinate2DMake(mapLatitude, mapLongitude)
//            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
//            let options = [
//                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
//                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
//            ]
//            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//            let mapItem = MKMapItem(placemark: placemark)
//            mapItem.name = "My Park"
//            mapItem.openInMaps(launchOptions: options)
//        }
//
//    func createTripDb(){
//        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Mytrip.sqlite")
//
//        if sqlite3_open( fileUrl.path, &db) != SQLITE_OK{
//            print("Error opening database")
//            return
//        }
//
//        let createTableQuery = "CREATE TABLE IF NOT EXISTS Mytrip ( id INTEGER PRIMARY KEY AUTOINCREMENT, start TEXT, stop TEXT, average FLOAT, max FLOAT, distance FLOAT, time DOUBLE, lat DOUBLE, long DOUBLE)"
//
//        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
//            print("Error creating table")
//            return
//        }
//
//        print("Database is created! Ok")
//    }
//
//    }
    
    
    
    }
}
