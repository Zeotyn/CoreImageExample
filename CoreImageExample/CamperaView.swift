//
//  CamperaView.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

class CameraView: UIView {
    let imageView = UIImageView()
    let previewLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .none

        self.layer.addSublayer(previewLayer)
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
