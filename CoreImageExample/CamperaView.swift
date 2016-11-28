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
    let button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .none

        self.layer.addSublayer(previewLayer)
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.backgroundColor = .white
        button.titleLabel?.text = "Take the picture"
        button.tintColor = .black
        self.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
            make.left.equalToSuperview().offset(150)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
