//
//  BeaconModel.swift
//  MyKlan
//
//  Created by Tejisav Brar on 2019-07-30.
//  Copyright © 2019 Team Lion. All rights reserved.
//

import UIKit
import CoreLocation

struct BeaconModel {
    var id: String?
    var title: String?
    var coordinate: CLLocationCoordinate2D?
    var radius: CLLocationDistance?
    var members: [String]?
    var onExit: Bool?
    var onEntry: Bool?
}
