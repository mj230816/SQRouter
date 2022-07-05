//
//  ViewController.swift
//  SQRouter
//
//  Created by mj230816 on 08/04/2021.
//  Copyright (c) 2021 mj230816. All rights reserved.
//

import UIKit
import SQRouter

let scheme = "scheme"

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let button = UIButton()
        button.backgroundColor = .red
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.addTarget(self, action: #selector(touch), for: .touchUpInside)
        view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func touch() {
        
        UIViewController.openContant(.bviewController(intValue: 88, stringValue: "asdjfklsdjkf"))
    }
    
}

class BViewController: UIViewController {
    
    @objc var intValue: Int = 0
    @objc var stringValue: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red //
        
        print("intValue:\(intValue)")
        print("stringValue:\(stringValue)")
    }
}
