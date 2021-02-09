//
//  TextViewController.swift
//  Notes
//
//  Created by pro2017 on 09/02/2021.
//

import UIKit


class TextViewController: UIViewController {
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(named: "ButtonColor")
    }
    

    @IBAction func closeTextVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}


