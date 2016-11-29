//
//  PictureView.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 30.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class PictureView: UIView {
    let closeButton = UIButton()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        [imageView, closeButton].forEach { value in
            self.addSubview(value)
        }

        closeButton.backgroundColor = .white
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalTo(self.snp.top).offset(20)
            make.left.equalTo(self.snp.left).offset(20)
        }

        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
