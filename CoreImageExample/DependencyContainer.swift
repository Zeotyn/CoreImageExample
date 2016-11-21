//
//  DependencyContainer.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import Foundation
import Swinject

class DependencyContainer {
    let container = Container() { c in
        c.register(CameraViewController.self) { r in
            let view = CameraView()
            
            let controller = CameraViewController.init(cameraView: view)

            return controller
        }
    }
}
