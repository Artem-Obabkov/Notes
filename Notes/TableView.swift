//
//  TableView.swift
//  Notes
//
//  Created by pro2017 on 09/02/2021.
//

import UIKit

class TableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCell
            
//        cell.textLabel?.text = "test"
//        cell.textLabel?.textColor = UIColor(named: "PrimaryText")
            
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
