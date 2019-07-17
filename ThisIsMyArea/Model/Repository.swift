//
//  Repository.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 16/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Mapper

struct Repository: Mappable {
    
    let identifier: Int
    let language: String
    let name: String
    let fullName: String
    
    init(map: Mapper) throws {
        try identifier = map.from("id")
        try language = map.from("language")
        try name = map.from("name")
        try fullName = map.from("full_name")
    }
}
