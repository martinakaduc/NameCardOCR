//
//  ProcessRecognize.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import UIKit
import Vision
import AVFoundation
import TesseractOCR
//import SwiftOCR

protocol ProcessRecognizeDelegate: class {
    func processRecognize(_ service: ProcessRecognize, textDetect text: [String], full nameCard: UIImage)
}

final class ProcessRecognize: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let tesseract = G8Tesseract(language: "eng+vie")
    weak var delegate: ProcessRecognizeDelegate?
    
    func handle(cameraLayer: AVCaptureVideoPreviewLayer, image: UIImage, nameCard: UIImage, results: [VNTextObservation], on view: UIView) {
        var textResult: [String] = []
        var textImages: [UIImage] = []
        let results = results.filter({ $0.confidence > 0.5 })
        // Tesseract Configs
        tesseract?.engineMode = .tesseractOnly
        tesseract?.pageSegmentationMode = .singleBlock
        
        
//        let images:UIImage = OpenCVWrapper.imageDenoise(nameCard)
        
        for i in 0..<results.count {
            var vertec = [results[i].topLeft, results[i].topRight, results[i].bottomRight, results[i].bottomLeft]
            textImages.append(OpenCVWrapper.imageTransform(image, &vertec, true))
        }
        
        for eachImage in textImages {
            tesseract?.image = eachImage
            tesseract?.recognize()
            textResult.append(tesseract?.recognizedText ?? "")
        }

        textResult = postProcessText(text: textResult)!
        print(textResult)
        
        delegate?.processRecognize(self, textDetect: textResult, full: nameCard)
    }

}
