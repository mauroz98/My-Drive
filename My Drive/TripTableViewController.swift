//
//  TripTableViewController.swift
//  My Drive
//
//  Created by Michele Navolio on 21/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import SQLite3
import MapKit

class TripTableViewController: UITableViewController {
    
    var db : OpaquePointer!

    
    //    creo array che contiene i miei viaggi e lo inizializzo  vuoto
    var trips:[TripModel] = []
    var latitude : Double = 0
    var longitude : Double = 0
    
//    var tripString = [String]()

    
    func createTripDb(){
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Mytrip.sqlite")
        
        if sqlite3_open( fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Mytrip ( id INTEGER PRIMARY KEY AUTOINCREMENT, start TEXT, stop TEXT, average FLOAT, max FLOAT, distance FLOAT, time DOUBLE, lat DOUBLE, long DOUBLE)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        
        print("Database is created! Ok")
    }
    
    func selectTripFromDb(){
        
        trips = []
        
        var stmt : OpaquePointer?
        
        let readQuery = "SELECT * FROM Mytrip"
        
        if sqlite3_prepare_v2(db, readQuery, -1, &stmt, nil) != SQLITE_OK{
            print("Error reading query!")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW{
            
//            let start = sqlite3_column_text(stmt, 1)
            let start = String(cString: sqlite3_column_text(stmt, 1))
            let stop = String(cString: sqlite3_column_text(stmt, 2))
            let average = sqlite3_column_double(stmt, 3)
            let max = sqlite3_column_double(stmt, 4)
            let distance = sqlite3_column_double(stmt, 5)
            let time = sqlite3_column_double(stmt, 6)
            let lat = sqlite3_column_double(stmt, 7)
            let long = sqlite3_column_double(stmt, 8)
            
            print("Start: \(start) Stop: \(stop) Media: \(average) Max: \(max) Distanza: \(distance) Tempo: \(time)")
            let trip = TripModel.init(startTripDate: start, finishTripDate: stop, distance: Float(distance), averageSpeed: average, maxSpeed: max, timeTrip: time, latitude: lat, longitude: long)
            trips.append(trip)
            
        }
        sqlite3_finalize(stmt)
        
    }
    
//    func dataReturn(date: String) -> Date {
//        let tempDate = date
//        let tempFormatter = DateFormatter()
//        tempFormatter.timeZone = NSTimeZone(name: "UTC-12") as TimeZone?
//        tempFormatter.locale = Locale.current
//        let dataConverted = tempFormatter.date(from: tempDate)
//
//        return dataConverted!
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("tablebiew")
        
        createTripDb()
             
        selectTripFromDb()
        //        aggiungo manualmente all'array i viaggi esempio che ho creato

//        trips.append(viaggio1)
//        trips.append(viaggio2)
//
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        selectTripFromDb()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(trips.count)
        
        

        return trips.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TripTableViewCell
        
        // Configure the cell...
        
       
        let trip = trips[indexPath.row]
        
        
        cell.layer.cornerRadius = 10
        
        cell.layer.borderWidth = 7
        
//        cell.textLabel?.text = trip.startDateFormatter()
        
        cell.startView.layer.cornerRadius = 5
        cell.startView.backgroundColor = .blue
        cell.finishView.layer.cornerRadius = 5

        //da qua pesco i miei dati dall array
        //va estratto il giorno e il mese dalla data e messo nel campo giorno e mese
        let subData = trip.startTripDate.prefix(13)
        let subHour = trip.startTripDate.suffix(11)
        
//      let startDateFromTrip = dataReturn(date: trip.startTripDate)
        cell.giornoLabel.text = "\(subData)"
        cell.meseLabel.text = "\(subHour)"
        cell.distanzaPercorsa.text = String(format: "%.2f",(trip.distance/1000))
        cell.timeTravel.text = timeFormatter(trip.timeTrip)
        latitude = trip.parkLatitude
        longitude = trip.parkLongitude
        
        //va fatta funzionare il bottone che apre le coordinate del prk
        //cell. non lo so..coordinate. = il bottone sembra andare ma manca la func

        
        
        return cell
    }
    
    func openMapForPlace() {
          
          // Declaration of coordinates for map
          let mapLatitude : CLLocationDegrees = latitude
          let mapLongitude : CLLocationDegrees = longitude
          // Set distance of view for map
          let regionDistance : CLLocationDistance = 5000
          
          
          let coordinates = CLLocationCoordinate2DMake(mapLatitude, mapLongitude)
          let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
          let options = [
              MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
              MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
          ]
          let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
          let mapItem = MKMapItem(placemark: placemark)
          mapItem.name = "My Park"
          mapItem.openInMaps(launchOptions: options)
      }
    
    func timeFormatter(_ time : TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format: "%02i:%02i:%02i", hours, minutes, Int(seconds))
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}
