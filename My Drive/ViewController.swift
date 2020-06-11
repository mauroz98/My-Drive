//
//  ViewController.swift
//  My Drive
//
//  Created by Ugo Falanga on 20/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SQLite3


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Declaration of Outlet for label
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var averageSpeedLabel: UILabel!
    
    @IBOutlet var maxSpeedTitle: UILabel!
    @IBOutlet var maxSpeedLabel: UILabel!
    @IBOutlet var maxSpeedKMLabel: UILabel!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var parkLabel: UILabel!
    
    @IBOutlet var takeABreakLabel: UILabel!
    @IBOutlet var batteryImage: UIImageView!
    
    

    // Declaration of Outlet for button
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var openMapButton: UIButton!

    // Declaration of location manager
    let locationManager : CLLocationManager = CLLocationManager()
    
    // Declaration of trips array
    var trips:[TripModel] = []
    
    // Declaration of variables latitude and longitude
    var latitude : Double = Double()
    var longitude : Double = Double()
    
    // Declaration of variables initial latitude and initial longitude
    var initLatitude : Double = Double()
    var initLongitude : Double = Double()
    
    // Declaration of variables semaphore to give access to start and stop buttons
    var startSemaphore = true
    var stopSemaphore = true
    
    // Declaration of Timer
    var timer = Timer()
    var count : Double = 0
    
    // Declaration of variables for the trip info
    var tripTime : Double = 0
    var startDate : Date!
    var stopDate : Date!
    var distanceTraveled : Double = 0
    var maxSpeedTrip : Double = 0
    var averageSpeedTrip : Double = 0
    
    // Pointer for Database
    var db : OpaquePointer!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Creation and opening of Database
        createTripDb()
        
        locationManager.delegate = self

        parkLabel.isHidden = true
        openMapButton.isHidden = true
        stopButton.isEnabled = false
        
        takeABreakLabel.isHidden = true
        
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Gps Function
        locationManager.requestWhenInUseAuthorization()
        // For gps background monitoring
        locationManager.requestAlwaysAuthorization()
        
        // Updating
        locationManager.distanceFilter = 100
    
    }
    
    func velocitàMaxRaggiunta(velocita: Double){
        if maxSpeedTrip > 120.0 {
            maxSpeedTitle.textColor = .orange
            maxSpeedLabel.textColor = .orange
            maxSpeedKMLabel.textColor = .orange
            
            print("label velocita rossa")
            
        }
        
    }
    
    func batteryImage(contatore : Double) -> UIImage {
        let contatore = count
        var image = UIImage()
        
        switch contatore {
        case 0...3:
            image = UIImage(named: "Battery full")!
            print("immagine full")
        case 4...6:
            image = UIImage(named: "Battery 3")!
            print("immagine 2")
        case 7...9:
              image = UIImage(named: "Battery 2")!
                      print("immagine 3")
            case 10...14:
            image = UIImage(named: "Battery red 1")!
            takeABreakLabel.isHidden = false
                    print("immagine 4")
            case 15...20:
            image = UIImage(named: "Battery red exaust")!
            takeABreakLabel.isHidden = false
                    print("immagine 5")
        default:
            image = UIImage(named: "Battery red exaust")!
            takeABreakLabel.isHidden = false
            print("oltre i 20")
        }
                
        return image
    }
    
    // Map action
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        
        openMapForPlace()
        
    }
    
    // Start action
    @IBAction func startButtonPressed(_ sender: UIButton) {
        

        // Hide parking location
        openMapButton.isHidden = true
        parkLabel.isHidden = true
        
        
        print("Timer started")
        // Abilitate stop button
        stopButton.isEnabled = true
        stopButton.setTitleColor(.systemGray6, for: .normal)
        
        // Set start date
        if (startSemaphore) {
            startDate = Date()
        }
        // Start location update and allows background location update
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
        print("gps")
        
        // Set initial position
        initLatitude = ((locationManager.location?.coordinate.latitude)!)
        initLongitude = ((locationManager.location?.coordinate.longitude)!)
        
        print("Posizione iniziale \(initLatitude) , \(initLongitude)")
        
        if !timer.isValid {
            
            print("ho schiacciato start")
            
            // Change start button in pause button
            self.startButton.setTitle("Pause", for: .normal)

            
            startSemaphore = false
            
            // Start timer
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                
                // Check the amount of time
                if self.count == 10.0 {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "3 hours driving"
                    content.body = "You have been driving for 3h,take a break!"
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger (timeInterval: 0.000001, repeats: false)
                    let request = UNNotificationRequest (identifier: "testIdentifier", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
                
                // Increase variable count and print on screen the timer
                self.count += 1
                print(self.count)
                self.timerLabel.text = self.timeFormatter(self.count)
                
                self.batteryImage.isHidden = false
                self.batteryImage.image = self.batteryImage(contatore: self.count)
                
                self.velocitàMaxRaggiunta(velocita: self.maxSpeedTrip)

                
                // Set coordinates to calculate the distance from start
                let coordinates = CLLocation(latitude: self.initLatitude, longitude: self.initLongitude)
                let distance = self.locationManager.location?.distance(from: coordinates)
                self.distanceTraveled = distance!
                // Calculate the average speed
                let averageSpeed = (distance!/self.count) * 3.6
                self.averageSpeedTrip = averageSpeed
//                self.averageSpeedLabel.text = String(format :"%.2f", averageSpeed)
                
            }
        } else {
            // Invalidate the timer
            timer.invalidate()
            
            print("Timer paused")
            
            // Stop updating location and background location updating
            locationManager.stopUpdatingLocation()
            locationManager.allowsBackgroundLocationUpdates = false
            
            // Mutate color and title of button
            startButton.setTitle("Resume", for: .normal)

            startSemaphore = false
        }
        stopSemaphore = true
        
    }
    
    // Stop action
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        // Invalidate timer
        timer.invalidate()
        
        print("ho schiacciato stop")
        
        // Set stop data
        if(stopSemaphore){
            stopDate = Date()
        }
        
        // This is a print of time you have been driving
        print(timeFormatter(count))
        tripTime = count
        
        // Resetting start button
        startButton.setTitle("Start", for: .normal)
//        startButton.setTitleColor(.systemGreen, for: .normal)
        if(stopSemaphore){
            // Stop location update and backgroung location update
            self.locationManager.stopUpdatingLocation()
            self.locationManager.allowsBackgroundLocationUpdates = false
      
            
            let fieldAlert = UIAlertController(title: "Your trip is finish?",
                                               message: "",
                                               preferredStyle: .alert)
            
            
            
            fieldAlert.addAction( UIAlertAction(title: "Resume", style: .cancel) { action in
                // When resume button is pressed restart the location update
                self.locationManager.startUpdatingLocation()
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){timer in
                    self.count += 1
                    self.timerLabel.text = self.timeFormatter(self.count)
                    print("data a schermo")
                    
                    // Set coordinates to calculate the distance from start
                    let coordinates = CLLocation(latitude: self.initLatitude, longitude: self.initLongitude)
                    let distance = self.locationManager.location?.distance(from: coordinates)
                    self.distanceTraveled = distance!
                    // Calculate the average speed
                    let averageSpeed = (distance!/self.count) * 3.6
                    self.averageSpeedTrip = averageSpeed
                    self.averageSpeedLabel.text = "\(round(averageSpeed))"
                }
                
                self.stopButton.isEnabled = true
                print("ho fatto resume dallo stop")
            })
            
            fieldAlert.addAction( UIAlertAction(title: "Finish", style: .default) { (action) in
                // Show parking position
                self.parkLabel.isHidden = false
                self.openMapButton.isHidden = false

    
                // aggiungi qui il codice che deve essere eseguito quando viene premuto il pulsante
                self.timerLabel.text = self.timeFormatter(self.count)

                print("data a schermo")
                
                // Creation of new trip
                let startDateOfTrip = self.dateFormatter(date: self.startDate)
                let stopDateOfTrip = self.dateFormatter(date: self.stopDate)
                
                let newTrip = TripModel.init(startTripDate: startDateOfTrip, finishTripDate: stopDateOfTrip, distance: Float(self.distanceTraveled), averageSpeed: self.averageSpeedTrip, maxSpeed: self.maxSpeedTrip, timeTrip: self.tripTime, latitude: self.latitude, longitude: self.longitude )
                
                // Add new trip to array
                self.trips.append(newTrip)
                
                // Save trip into database
                self.saveTripIntoDb(trip: newTrip)
                
                // Read trip from db
//                self.selectTripFromDb()
                
                // Print in console the array of trips
                for trip in self.trips{
                    print("Viaggio start: \(trip.startTripDate), stop: \(trip.finishTripDate), distanza: \(trip.distance), media: \(trip.averageSpeed), max: \(trip.maxSpeed), tempo: \(trip.timeTrip), Lat: \(trip.parkLatitude), Long: \(trip.parkLongitude)")
                }
                
                // Invalidate timer
                self.timer.invalidate()
                // Reset count
                self.count = 0
                self.timerLabel.text = "00:00:00"
                print("Timer reset")
                
//                self.parkLabel.isHidden = false
//                self.openMapButton.isHidden = false
                self.stopButton.isEnabled = false
                self.takeABreakLabel.isHidden = true
                self.batteryImage.isHidden = true
                
                self.stopSemaphore = false
                self.startSemaphore = true
                
                // Stop Gps position update
                self.locationManager.stopUpdatingLocation()
                self.locationManager.allowsBackgroundLocationUpdates = false
                
            } )
            
            present(fieldAlert, animated: true, completion: nil)
            
        }
        
    }
    
    // Utility function for timer formatter
    func timeFormatter(_ time : TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format: "%02i:%02i:%02i", hours, minutes, Int(seconds))
    }
    
    // Function for open apple maps
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
    
    // Gps function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        for currentlocation in locations{
                // Assign coordinate
                latitude = currentlocation.coordinate.latitude
                longitude = currentlocation.coordinate.longitude
            
                print("Current location Lm\(latitude) , \(longitude)")
                // Calculate speed in Kilometer per hours
                let speedKilometer = (currentlocation.speed) * 3.6
                print("Velocità: \(speedKilometer)")
                // Declaration of coordinates to calculate distance
                let coordinates = CLLocation(latitude: initLatitude, longitude: initLongitude)
                // Calculate distance from start point (in Kilometer)
                let distanceInKm = (currentlocation.distance(from: coordinates))/1000
                print(distanceInKm)
                self.distanceLabel.text = String(format: "%.2f", Double(distanceInKm))
                // Calculate max speed of trip
                calculateMaxSpeed(speed: speedKilometer)
                maxSpeedLabel.text = String(format: "%.2f", maxSpeedTrip)
            }
            
        }
    
    
    func calculateMaxSpeed(speed : Double){
        if speed > self.maxSpeedTrip {
            print("cambia la velocità \(speed) > \(maxSpeedTrip)")
            self.maxSpeedTrip = speed
        } else{
            print("non cambia la velocità \(speed) < \(maxSpeedTrip)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        // To develop for understand user settings variation
    }

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
    
    func saveTripIntoDb( trip: TripModel ){
        let start = dateFormatter(date: startDate)
        let stop = dateFormatter(date: stopDate)
        let distance = trip.distance
        let time = trip.timeTrip
        let average = trip.averageSpeed
        let max = trip.maxSpeed
        let lat = trip.parkLatitude
        let long = trip.parkLongitude
        
        var stmt : OpaquePointer?
        
        let insertQuery = "INSERT INTO Mytrip (start, stop, average, max, distance, time, lat, long) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare(db, insertQuery, -1, &stmt, nil) != SQLITE_OK{
            print("Error binding query!")
        }
        
        if sqlite3_bind_text(stmt, 1, start, -1, nil) != SQLITE_OK{
            print("Error binding start date!")
        }
        
        if sqlite3_bind_text(stmt, 2, stop, -1, nil) != SQLITE_OK{
            print("Error binding stop date!")
        }
        
        if sqlite3_bind_double(stmt, 3, Double(average)) != SQLITE_OK{
            print("Error binding average speed!")
        }
        
        if sqlite3_bind_double(stmt, 4, Double(max)) != SQLITE_OK{
            print("Error binding max speed!")
        }
        
        if sqlite3_bind_double(stmt, 5, Double(distance)) != SQLITE_OK{
            print("Error binding distance!")
        }
        
        if sqlite3_bind_double(stmt, 6, Double(time)) != SQLITE_OK{
            print("Error binding time!")
        }
        
        if sqlite3_bind_double(stmt, 7, Double(lat)) != SQLITE_OK{
            print("Error binding latitude!")
        }
        
        if sqlite3_bind_double(stmt, 8, Double(long)) != SQLITE_OK{
            print("Error binding longitude!")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE {
            print("Trip saved successfully!")
        }
        
        sqlite3_finalize(stmt)
    }
    
    func selectTripFromDb(){
        
        var stmt : OpaquePointer?
        
        let readQuery = "SELECT * FROM Mytrip"
        
        if sqlite3_prepare_v2(db, readQuery, -1, &stmt, nil) != SQLITE_OK{
            print("Error reading query!")
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW{
            
            let start = String(cString: sqlite3_column_text(stmt, 1))
            let stop = String(cString: sqlite3_column_text(stmt, 2))
            let average = sqlite3_column_double(stmt, 3)
            let max = sqlite3_column_double(stmt, 4)
            let distance = sqlite3_column_double(stmt, 5)
            let time = sqlite3_column_double(stmt, 6)
            let lat = sqlite3_column_double(stmt, 7)
            let long = sqlite3_column_double(stmt, 8)
            
            print("Start: \(String(describing: start)) Stop: \(String(describing: stop)) Media: \(average) Max: \(max) Distanza: \(distance) Tempo: \(time) Pos: \(lat) - \(long)")
            
        }
        sqlite3_finalize(stmt)
    }
    
    func dateFormatter(date: Date) -> String {
        let tempDate = date
        let tempFormatter = DateFormatter()
        tempFormatter.dateFormat = "hh:mm:ss dd/MM/yyyy"
        tempFormatter.timeStyle = .medium
        tempFormatter.dateStyle = .medium
        let dateFormatted = tempFormatter.string(from: tempDate)

        return dateFormatted
    }
    
    func dataReturn(date: String) -> Date {
        let tempDate = date
        let tempFormatter = DateFormatter()
        tempFormatter.timeZone = NSTimeZone(name: "UTC-12") as TimeZone?
        tempFormatter.locale = Locale.current
        let dataConverted = tempFormatter.date(from: tempDate)
        
        return dataConverted!
    }


}
