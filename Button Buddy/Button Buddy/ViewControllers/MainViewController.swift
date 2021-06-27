//
//  MainViewController.swift
//  Button Buddy
//
//  Created by Justin Snider on 5/2/21.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var bleTableView: UITableView!
    
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: BluetoothService.BluetoothDeviceDiscoveredNotification, object: nil, queue: .main) { [weak self] notification in
            self?.bleTableView.reloadData()
        }
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothService.shared.buddies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BleCell", for: indexPath) as! BleTableViewCell
        
        cell.nameLabel.text = BluetoothService.shared.buddies[indexPath.row].peripheral?.name
        cell.buttonBuddy = BluetoothService.shared.buddies[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = navigationController else { return }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ButtonSettingsVC") as! ButtonSettingsViewController
        
        vc.buttonBuddy = BluetoothService.shared.buddies[indexPath.row]
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    
}
