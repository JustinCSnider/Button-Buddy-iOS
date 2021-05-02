//
//  ButtonPeripheral.swift
//  Button Buddy
//
//  Created by Justin Snider on 5/2/21.
//

import UIKit
import CoreBluetooth

class ButtonPeripheral: NSObject {

    public static let buttonUARTServiceUUID     = CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let txCharacteristicUUID      = CBUUID.init(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    public static let rxCharacteristicUUID      = CBUUID.init(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

}
