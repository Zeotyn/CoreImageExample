//
//  ViewController.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    var cameraView: CameraView

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = self.view.frame
        self.view.addSubview(cameraView)
    }

    init(cameraView: CameraView) {
        self.cameraView = cameraView

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

