//
//  FindTextArea.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import Vision
import AVFoundation
import UIKit

protocol FindTextAreaDelegate: class {
    func findTextArea(_ version: FindTextArea, didDetect image: UIImage, namecard:UIImage, results: [VNTextObservation])
}

final class FindTextArea {
    
    weak var delegate: FindTextAreaDelegate?
    
    func handle(image: UIImage) {
        
        makeRequest(image: image)
    }
    
    private func inferOrientation(image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up:
//            print("UP")
            return CGImagePropertyOrientation.up
        case .upMirrored:
//            print("UP_")
            return CGImagePropertyOrientation.upMirrored
        case .down:
//            print("DOWN")
            return CGImagePropertyOrientation.down
        case .downMirrored:
//            print("DOWN_")
            return CGImagePropertyOrientation.downMirrored
        case .left:
//            print("LEFT")
            return CGImagePropertyOrientation.left
        case .leftMirrored:
//            print("LEFT_")
            return CGImagePropertyOrientation.leftMirrored
        case .right:
//            print("RIGHT")
            return CGImagePropertyOrientation.right
        case .rightMirrored:
//            print("RIGHT_")
            return CGImagePropertyOrientation.rightMirrored
        }
    }
    
    private func makeRequest(image: UIImage) {
        
        var imageProcess:UIImage = OpenCVWrapper.image2Gray(image)
        imageProcess = OpenCVWrapper.imageThreshold(imageProcess)
        
        guard let cgImage = imageProcess.cgImage else {
            assertionFailure()
            return
        }
        
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: CGImagePropertyOrientation(imageProcess.imageOrientation),
            options: [VNImageOption: Any]()
        )
        
        let request = VNDetectTextRectanglesRequest(completionHandler: { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handle(image: imageProcess, namecard: image, request: request, error: error)
            }
        })
        
        request.reportCharacterBoxes = true
        
        do {
            try handler.perform([request])
        } catch {
            print(error as Any)
        }
    }
    
    private func handle(image: UIImage, namecard: UIImage, request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNTextObservation]
        else {
                return
        }
        // Nosie removing
        
        delegate?.findTextArea(self, didDetect: image, namecard: namecard, results: results)
    }
}
