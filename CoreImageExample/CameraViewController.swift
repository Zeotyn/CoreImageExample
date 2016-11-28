//
//  ViewController.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import CoreImage

class CameraViewController: UIViewController {
    var cameraView: CameraView
    var pictureViewModel: PictureViewModel

    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: CIContext(), options: [CIDetectorAccuracy : CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.0])
    let queue = DispatchQueue(label: "sampleBuffer")

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = self.view.frame
        self.view.addSubview(cameraView)
        self.cameraView.button.reactive.pressed = CocoaAction(pictureViewModel.action, {_ in
                return "foooooobbbbaaaar"
            }
        )
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        DispatchQueue.main.async {
            if let highlightedImage = self.performRectangleDetection(image: cameraImageTransformed) {
                let filteredImage = UIImage(ciImage: highlightedImage)
                self.cameraView.imageView.image = filteredImage
            } else {
                self.cameraView.imageView.image = nil
            }
        }
    }

    func performRectangleDetection(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        if let detector = detector {
            // Get the detections
            let imageWithFilter: CIImage = image.applyingFilter("CIColorControls", withInputParameters: [kCIInputImageKey : image, kCIInputSaturationKey: 3.0, kCIInputContrastKey: 1.0])

            let features = detector.features(in: imageWithFilter)
            for feature in features as! [CIRectangleFeature] {
                resultImage = drawHighlightOverlayForPoints(
                    image: image,
                    topLeft: feature.topLeft,
                    topRight: feature.topRight,
                    bottomLeft: feature.bottomLeft,
                    bottomRight: feature.bottomRight
                )
            }
        }
        return resultImage
    }

    func drawHighlightOverlayForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 0, green: 1.0, blue: 0, alpha: 0.5))
        var background = CIImage(color: CIColor(color: .black))
        background = background.cropping(to: image.extent)
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

        // todo: do perspectives without blending filter.
        let context = CIContext()

        background = background.applyingFilter("CIBlendWithMask", withInputParameters: [
            kCIInputImageKey: image,
            kCIInputMaskImageKey: overlay,
            kCIInputBackgroundImageKey: background
            ]
        )

        background = image.applyingFilter("CIPerspectiveCorrection", withInputParameters: [
            kCIInputImageKey: background,
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
