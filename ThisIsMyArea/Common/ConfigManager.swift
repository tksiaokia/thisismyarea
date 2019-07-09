//
//  Config.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 09/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
class ConfigManager {
    static let shared = ConfigManager()
    //Note: all distance measured in meters
    var isWalking:Bool!
    var regionRadius:Double!
    var nearestRadius:Double!
    var maxMonitoringCount:Int = 5
    
    
    init() {
        setup(isWalking: false)
    }
    
    func setup(isWalking:Bool){
        self.isWalking = isWalking
        if(isWalking){
            regionRadius = 10
            nearestRadius = 1 * 1000 //1 km
        }else{
            regionRadius = 200
            nearestRadius = 5 * 1000  //2 km far
        }
    }
    

}
