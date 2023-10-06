//
//  ViewController.swift
//  Player
//
//  Created by Riddhi Makwana on 06/10/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnBack(_ sender  : UIButton){
        self.navigationController?.popViewController(animated: true)
    }

}

