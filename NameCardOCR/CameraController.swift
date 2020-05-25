//
//  CameraController.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreMotion

protocol CameraControllerDelegate: class {
    func cameraController(_ controller: CameraController, didCapture buffer: CVPixelBuffer, acceleration data: [Double])
    
}

final class CameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    private var photoOutput: AVCapturePhotoOutput?
    
    private let motion = CMMotionManager()
    
    private(set) lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else {
                return session
        }
        
        session.addInput(input)
        return session
    }()
    
    weak var delegate: CameraControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        
        let photoOutput = AVCapturePhotoOutput()
        self.photoOutput = photoOutput
        
        self.captureSession.addOutput(photoOutput)
        
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.motion.startAccelerometerUpdates()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // make sure the layer is the correct size
        self.cameraLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Sets the status bar to hidden when the view has finished appearing
        // let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        // statusBar.isHidden = true
        self.captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Sets the status bar to visible when the view is about to disappear
        // let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        // statusBar.isHidden = false
        self.captureSession.stopRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard let pixelBuffer = photo.pixelBuffer else {
            print("No pixel buffer provided. Settings may missing pixel format")
            return
        }
        
        if let data = self.motion.accelerometerData {
            let accelerationData = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
            delegate?.cameraController(self, didCapture: pixelBuffer, acceleration: accelerationData)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let formats = photoOutput?.supportedPhotoPixelFormatTypes(for: .tif) else { return }
        guard let uncompressedPixelType = formats.first else {
            return
        }
        
        let settings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: uncompressedPixelType])
        settings.flashMode = .auto
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}
