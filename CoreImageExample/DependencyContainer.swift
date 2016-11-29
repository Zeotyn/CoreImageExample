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
    let container = Container() { container in
        container.register(PictureViewModel.self) { r in
            let viewModel = PictureViewModel()
            return viewModel
        }
        .inObjectScope(.container)

        container.register(CameraViewController.self) { r in
            let view = CameraView()
            let viewModel = container.resolve(PictureViewModel.self)
            let controller = CameraViewController.init(cameraView: view, withViewModel: viewModel!)
            return controller
        }

        container.register(PictureViewController.self) { r in
            let view = PictureView()
            let viewModel = container.resolve(PictureViewModel.self)
            let controller = PictureViewController(pictureView: view, viewModel: viewModel!)
            return controller
        }
    }
}
