//
//  TripModel.swift
//  My Drive
//
//  Created by Ugo Falanga on 20/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation

class TripModel: Codable {
    


    var startTripDate : String
    var finishTripDate : String
    var distance : Float
    var averageSpeed : Double
    var maxSpeed : Double
    var timeTrip : Double
    var parkLatitude : Double
    var parkLongitude : Double
    
        
    
    init(startTripDate: String, finishTripDate : String, distance: Float, averageSpeed : Double, maxSpeed: Double, timeTrip: Double, latitude: Double, longitude: Double) {
        self.startTripDate = startTripDate
        self.finishTripDate = finishTripDate
        self.distance = distance
        self.averageSpeed = averageSpeed
        self.maxSpeed = maxSpeed
        self.timeTrip = timeTrip
        self.parkLatitude = latitude
        self.parkLongitude = longitude
        
    }
}
