//
//  WeatherCondition.swift
//  NBUtility
//
//  Created by Fahid Attique on 5/30/17.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import Foundation
import ObjectMapper


class WeatherCondition: NSObject, Mappable {
    
    var LocalObservationDateTime: String = ""
    var EpochTime:String = ""
    var WeatherText:String = ""
    var WeatherIcon:NSNumber = 0
    var IsDayTime:Bool = false
    
    
    // MARK:- Overidden Methods
    
    override init() {
        super.init()
    }
    
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        
        LocalObservationDateTime <- map["LocalObservationDateTime"]
        EpochTime <- map["EpochTime"]
        WeatherText <- map["WeatherText"]
        WeatherIcon <- map["WeatherIcon"]
        IsDayTime <- map["true"]
    }
}
