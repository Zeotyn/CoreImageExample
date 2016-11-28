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
    let action = Action<String, Void, NoError> { value in
        return SignalProducer<Void, NoError> { observer, _ in
            print("foobar")
            print(value)
            observer.sendCompleted()
        }
    }
}
