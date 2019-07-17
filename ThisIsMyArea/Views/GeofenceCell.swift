//
//  GeofenceCell.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 12/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class GeofenCell: UITableViewCell {
    static let Identifier = "GeofenCell"
 
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    func configureWithChocolate(vm: GeofenceViewModel) {
        label.text = vm.geofence.title
     
       
    }
}
