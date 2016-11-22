//
//  ViewController.swift
//  CoreImageExample
//
//  Created by Eugen Waldschmidt on 21.11.16.
//  Copyright © 2016 Eugen Waldschmidt. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var cameraView: CameraView

    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.frame = self.view.frame
        self.view.addSubview(cameraView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetPhoto
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try? AVCaptureDeviceInput(device: backCamera)
        if let session = session {
            if session.canAddInput(input) {
                session.addInput(input)
            }


            stillImageOutput = AVCapturePhotoOutput()
            if session.canAddOutput(stillImageOutput) {
                session.addOutput(stillImageOutput)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                if let videoPreviewLayer = videoPreviewLayer {
                    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    cameraView.layer.addSublayer(videoPreviewLayer)
                    session.startRunning()
                    videoPreviewLayer.frame = cameraView.bounds
                }
            }
        }
    }

    init(cameraView: CameraView) {
        self.cameraView = cameraView

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

