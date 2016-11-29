//
//  PictureViewModel.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 28.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift
import Result

class PictureViewModel {
    let image: MutableProperty<UIImage?> = MutableProperty(nil)
    let closeEvent = MutableProperty(false)

    func buttonAction() -> Action<UIImage?, Void, NoError> {
        let action = Action<UIImage?, Void, NoError> { value in
            return SignalProducer<Void, NoError> { observer, _ in
                self.image.value = value
                observer.sendCompleted()
            }
        }

        return action
    }

//    func correctImage(_ image: CIImage) {
        // todo: do perspectives without blending filter.
//        let context = CIContext()

//        background = background.cropping(to: image.extent)
//        background = background.applyingFilter("CIBlendWithMask", withInputParameters: [
//            kCIInputImageKey: image,
//            kCIInputMaskImageKey: overlay,
//            kCIInputBackgroundImageKey: background
//            ]
//        )
//        image = image.applyingFilter("CIPerspectiveCorrection", withInputParameters: [
//            kCIInputImageKey: image,
//            "inputTopLeft": CIVector(cgPoint: topLeft),
//            "inputTopRight": CIVector(cgPoint: topRight),
//            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//            "inputBottomRight": CIVector(cgPoint: bottomRight)
//            ]
//        )
//    }
}
