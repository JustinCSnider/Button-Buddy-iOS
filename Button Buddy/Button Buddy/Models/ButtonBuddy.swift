//
//  ButtonBuddy.swift
//  Button Buddy
//
//  Created by Justin Snider on 6/27/21.
//

import Foundation
import CoreBluetooth

class ButtonBuddy: NSObject {
    
    // MARK: - Properties
    
    var peripheral: CBPeripheral?
    
    // MARK: - Initializers
    
    init(peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
    }
    
}
