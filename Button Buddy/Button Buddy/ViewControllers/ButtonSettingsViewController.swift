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
    
    var buttonBuddy: ButtonBuddy?
    
    private let pickerValues: [Int] = [5, 30, 60, 90, 120]
    
    private let timerPrefix = "!T"
    
    // MARK: Characteristics
    
    private var txChar: CBCharacteristic?
    private var rxChar: CBCharacteristic?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        guard let peripheral = buttonBuddy?.peripheral else { return }
        peripheral.delegate = self
        BluetoothService.shared.centralManager.connect(peripheral, options: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        guard let navigationController = navigationController else { return }
        if let peripheral = buttonBuddy?.peripheral {
            BluetoothService.shared.centralManager.cancelPeripheralConnection(peripheral)
        }
        navigationController.popViewController(animated: true)
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
        titleLabel.text = buttonBuddy?.peripheral?.name
    }

}

// MARK: - CBPeripheralDelegate

extension ButtonSettingsViewController: CBPeripheralDelegate {

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
        guard let peripheral = buttonBuddy?.peripheral else { return }
        var data = Data()
        let countDownDuration: UInt8 = UInt8(pickerValues[row])
        data.append(timerPrefix.data(using: .utf8)!)
        data.append(countDownDuration)
        appendCRC(&data)
        peripheral.writeValue(data, for: txChar!, type: .withoutResponse)
    }
    
}
