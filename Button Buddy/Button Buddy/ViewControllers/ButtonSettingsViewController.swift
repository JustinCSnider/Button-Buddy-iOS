//
//  ButtonSettingsViewController.swift
//  Button Buddy
//
//  Created by Justin Snider on 5/2/21.
//

import UIKit
import CoreBluetooth

class ButtonSettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let pickerValues: [Int] = [5, 30, 60, 90, 120]
    
    private let timerPrefix = "!T"
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    // MARK: Characteristics
    
    private var txChar: CBCharacteristic?
    private var rxChar: CBCharacteristic?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var timePicker: UIPickerView!
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Helper Functions
    
    private func appendCRC(_ data: inout Data) {
        //append crc
        let len = data.count
        
        var bdata = [UInt8](repeating: 0, count: len)
        var crc: UInt8 = 0
        data.copyBytes(to: &bdata, count: len)
        
        for i in bdata { // add all bytes
            crc = crc &+ i
        }
        
        crc = ~crc
        
        data.append(crc)
    }

}

// MARK: - CBPeripheralDelegate, CBCentralManagerDelegate

extension ButtonSettingsViewController: CBPeripheralDelegate, CBCentralManagerDelegate {
    
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

        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)

    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to your Button Board")
            peripheral.discoverServices([ButtonPeripheral.buttonUARTServiceUUID])
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == ButtonPeripheral.buttonUARTServiceUUID {
                    print("UART service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([ButtonPeripheral.txCharacteristicUUID, ButtonPeripheral.rxCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == ButtonPeripheral.txCharacteristicUUID {
                    print("TX characteristic found")
                    txChar = characteristic
                    timePicker.isUserInteractionEnabled = true
                } else if characteristic.uuid == ButtonPeripheral.rxCharacteristicUUID {
                    print("RX characteristic found")
                    rxChar = characteristic
                }
            }
        }
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension ButtonSettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerValues[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var data = Data()
        let countDownDuration: UInt8 = UInt8(pickerValues[row])
        data.append(timerPrefix.data(using: .utf8)!)
        data.append(countDownDuration)
        appendCRC(&data)
        peripheral.writeValue(data, for: txChar!, type: .withoutResponse)
    }
    
}
