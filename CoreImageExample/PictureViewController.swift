//
//  PictureViewController.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 30.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import ReactiveSwift

class PictureViewController: UIViewController {
    let pictureView: PictureView
    let viewModel: PictureViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(pictureView)
        self.pictureView.frame = self.view.frame

        self.pictureView.closeButton.reactive.pressed = CocoaAction(viewModel.buttonAction(), {_ in
            guard let cameraViewController = DependencyContainer().container.resolve(CameraViewController.self) else {
                return nil
            }
            self.present(cameraViewController, animated: false, completion: nil)
            return nil
        })

        self.pictureView.imageView.reactive.image <~ viewModel.image
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.pictureView.imageView.image = viewModel.image.value
    }

    init(pictureView: PictureView, viewModel: PictureViewModel) {
        self.pictureView = pictureView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
