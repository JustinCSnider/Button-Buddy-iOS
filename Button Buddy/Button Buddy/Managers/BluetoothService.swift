//
//  BluetoothService.swift
//  Button Buddy
//
//  Created by Justin Snider on 6/27/21.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject {
    
    // MARK: - Static Properties
    
    static var shared = BluetoothService()
    static var BluetoothDeviceDiscoveredNotification: Notification.Name = Notification.Name(rawValue: "BluetoothDeviceDiscovered")
    
    // MARK: - Properties
    
    lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: nil)
    
    var buddies: [ButtonBuddy] = [] {
        didSet {
            NotificationCenter.default.post(name: BluetoothService.BluetoothDeviceDiscoveredNotification, object: nil)
        }
    }
    
    // MARK: - Overrides
    
    override init() {
        super.init()
        let _ = centralManager
    }
    
}

// MARK: - CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", ButtonPeripheral.buttonUARTServiceUUID);
            centralManager.scanForPeripherals(withServices: [ButtonPeripheral.buttonUARTServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // Copy the peripheral instance
        buddies.append(ButtonBuddy(peripheral: peripheral))
    }
}
