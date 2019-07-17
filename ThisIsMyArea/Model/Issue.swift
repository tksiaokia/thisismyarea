//
//  Issue.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 16/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Mapper

struct Issue: Mappable {
    
    let identifier: Int
    let number: Int
    let title: String
    let body: String
    
    init(map: Mapper) throws {
        try identifier = map.from("id")
        try number = map.from("number")
        try title = map.from("title")
        try body = map.from("body")
    }
}
