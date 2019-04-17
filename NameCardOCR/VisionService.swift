//
//  VisionService.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import Vision
import UIKit
import AVFoundation

protocol VisionServiceDelegate: class {
    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNRectangleObservation])
}

final class VisionService {
    
    weak var delegate: VisionServiceDelegate?
    
    func handle(buffer: CVPixelBuffer, data: [Double]) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
//            return
//        }
        
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let ciImage = CIImage(cvPixelBuffer: buffer)
        guard var image = ciImage.toUIImage() else {
            return
        }
        if (abs(data[0]) >= abs(data[1])) {
            if (data[0] > 0) {
                image = OpenCVWrapper.imageRotate(image, 180.0)
            }
        } else {
            if (data[1] > 0) {
                image = OpenCVWrapper.imageRotate(image, 90.0)
            } else {
                image = OpenCVWrapper.imageRotate(image, 270.0)
            }
        }
        makeRequest(image: image)
    }
    
    private func inferOrientation(image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:
            return CGImagePropertyOrientation.up
        case .upMirrored:
            return CGImagePropertyOrientation.upMirrored
        case .down:
            return CGImagePropertyOrientation.down
        case .downMirrored:
            return CGImagePropertyOrientation.downMirrored
        case .left:
            return CGImagePropertyOrientation.left
        case .leftMirrored:
            return CGImagePropertyOrientation.leftMirrored
        case .right:
            return CGImagePropertyOrientation.right
        case .rightMirrored:
            return CGImagePropertyOrientation.rightMirrored
        }
    }
    
    private func makeRequest(image: UIImage) {
//        print(image)
//        print("\(OpenCVWrapper.openCVVersionString())")
//        OpenCVWrapper.processImage(image)
        guard let cgImage = image.cgImage else {
            assertionFailure()
            return
        }
        //        print(cgImage)
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: CGImagePropertyOrientation(image.imageOrientation),
            options: [VNImageOption: Any]()
        )
        
        let request = VNDetectRectanglesRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handle(image: image, request: request, error: error)
            }
        })
        
        request.minimumConfidence = 0.5
        
        do {
            try handler.perform([request])
        } catch {
            print(error as Any)
        }
    }
    
    private func handle(image: UIImage, request: VNRequest, error: Error?) {
        guard
            let results = request.results as? [VNRectangleObservation]
        else {
                return
        }
        
        delegate?.visionService(self, didDetect: image, results: results)
    }
}
