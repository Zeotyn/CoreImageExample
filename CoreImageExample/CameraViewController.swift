//
//  ViewController.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import ReactiveCocoa
import CoreImage

class CameraViewController: UIViewController {
    var cameraView: CameraView
    var pictureViewModel: PictureViewModel

    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var stillImage: UIImage?

    let detector = CIDetector(ofType: CIDetectorTypeFace, context: CIContext(), options: nil)
    let queue = DispatchQueue(label: "sampleBuffer")

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = self.view.frame
        self.view.addSubview(cameraView)
        self.cameraView.button.reactive.pressed = CocoaAction(pictureViewModel.buttonAction(), { _ in
            if let image = self.stillImage {
                guard let pictureViewController = DependencyContainer().container.resolve(PictureViewController.self) else {
                    return nil
                }
                self.pictureViewModel.image.value = image
                self.present(pictureViewController, animated: false, completion: nil)
                return image
            } else {
                return nil
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configureCamera()
    }

    init(cameraView: CameraView, withViewModel viewModel: PictureViewModel) {
        self.cameraView = cameraView
        self.pictureViewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)

        /// todo: make it flexible!
        let cameraImageTransformed = ciImage.applyingOrientation(6)

        /// todo: change the thread
        DispatchQueue.global().async() {
            if let highlightedImage = self.performRectangleDetection(image: cameraImageTransformed) {
                let filteredImage = UIImage(ciImage: highlightedImage)

                DispatchQueue.main.async {
                    self.cameraView.imageView.image = filteredImage
                    self.stillImage = filteredImage
                }
            } else {
                DispatchQueue.main.async {
                    self.cameraView.imageView.image = nil
                    self.stillImage = nil
                }
            }
        }
    }

    func performRectangleDetection(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        if let detector = detector {
            // Get the detections
            let features = detector.features(in: image)
            for feature in features as! [CIFaceFeature] {
                resultImage = hideFace(for: image, with: feature.bounds)
            }
        }
        return resultImage
    }


    func hideFace(for image: CIImage, with bounds: CGRect) -> CIImage {
        var overlay = CIImage(color: CIColor(color: .white))
        let background = CIImage(color: CIColor(color: .black))
        overlay = overlay.cropping(to: bounds)
        overlay = overlay.compositingOverImage(background)

        return overlay.applyingFilter("CIMaskedVariableBlur", withInputParameters: [kCIInputImageKey: image, "inputMask": overlay, "inputRadius": 100.0])
    }

//    func showEyesAnMouth(for image: CIImage, with feature: CIFaceFeature) -> CIImage {
//        let leftEye = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
//        let rightEye = CIImage(color: CIColor(red: 0, green: 1.0, blue: 0, alpha: 0.5))
//        let mouth = CIImage(color: CIColor(red: 0, green: 0, blue: 1.0, alpha: 0.5))
//
//        leftEye.cropping(to: CGRect(origin: feature.leftEyePosition, size: CGSize(width: 20, height: 20)))
//        rightEye.cropping(to: CGRect(origin: feature.rightEyePosition, size: CGSize(width: 20, height: 20)))
//        mouth.cropping(to: CGRect(origin: feature.mouthPosition, size: CGSize(width: 50, height: 20)))
//
//        var image = leftEye.compositingOverImage(image)
//        return image
//    }

    func drawHighlightOverlayForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1))
        overlay = overlay.cropping(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         withInputParameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
            ]
        )

        return overlay.compositingOverImage(image)
    }

    func configureCamera() {
        stillImageOutput = AVCapturePhotoOutput()

        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try? AVCaptureDeviceInput(device: backCamera)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        if let session = session {
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            if session.canAddOutput(stillImageOutput) {
                session.addOutput(stillImageOutput)
            }

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            if let videoPreviewLayer = videoPreviewLayer {
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                cameraView.previewLayer.addSublayer(videoPreviewLayer)
                videoPreviewLayer.frame = cameraView.bounds
                session.startRunning()
            }
        }
    }
}
