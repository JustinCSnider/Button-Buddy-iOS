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
    
    private let timerPrefix = "!T"
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    // Characteristics
    private var txChar: CBCharacteristic?
    private var rxChar: CBCharacteristic?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func timerSliderValueChanged(_ sender: UISlider) {
        timerLabel.text = "Timer: \(round(sender.value))"
        var data = Data()
        let slider: UInt8 = UInt8(round(sender.value))
        data.append(timerPrefix.data(using: .utf8)!)
        data.append(slider)
        appendCRC(&data)
        peripheral.writeValue(data, for: txChar!, type: .withoutResponse)
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
    
    // MARK: - Setup Functions
    
    private func setupViews() {
        timerLabel.text = "Timer: \(timerSlider.value)"
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
                    timerSlider.isEnabled = true
                } else if characteristic.uuid == ButtonPeripheral.rxCharacteristicUUID {
                    print("RX characteristic found")
                    rxChar = characteristic
                }
            }
        }
    }
}
