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
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BleCell", for: indexPath) as! BleTableViewCell
        
        return cell
    }
    
    
}
