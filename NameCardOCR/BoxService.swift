//
//  BoxService.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import UIKit
import Vision
import AVFoundation

protocol BoxServiceDelegate: class {
    func boxService(_ service: BoxService, didDetect images: [UIImage])
}

final class BoxService: UIViewController {
    weak var delegate: BoxServiceDelegate?
    
    func handle(cameraLayer: AVCaptureVideoPreviewLayer, image: UIImage, results: [VNRectangleObservation], on view: UIView) {
//        print(image.size)
        var images: [UIImage] = []
        let results = results.filter({ $0.confidence > 0.5 })
        
        for i in 0..<results.count {
            var vertec = [results[i].topLeft, results[i].topRight, results[i].bottomRight, results[i].bottomLeft]
            images.append(OpenCVWrapper.imageTransform(image, &vertec, false))
        }
        
        delegate?.boxService(self, didDetect: images)
    }
    
}
