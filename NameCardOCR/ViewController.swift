//
//  ViewController.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/24/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation
import UIKit
import Anchors
import Vision
import AVFoundation
import CoreMotion

class ViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let cameraController = CameraController()
    private let visionService = VisionService()
    private let boxService = BoxService()
    private let findTextArea = FindTextArea()
    private let processRecognize = ProcessRecognize()
    private let resultViewController = ResultViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraController.delegate = self
        add(childController: cameraController)
        activate(
            cameraController.view.anchor.edges
        )
        visionService.delegate = self
        boxService.delegate = self
        findTextArea.delegate = self
        processRecognize.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}

extension ViewController: CameraControllerDelegate {
    func cameraController(_ controller: CameraController, didCapture buffer: CVPixelBuffer, acceleration data: [Double]) {
//        print(data)
        visionService.handle(buffer: buffer, data: data)
    }
}

extension ViewController: VisionServiceDelegate {
    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNRectangleObservation]) {
        if (results.count > 0) {
            addBlurEffect()
            startIndicator()
        } else {
            return
        }
//        print(results.count)
        boxService.handle(
            cameraLayer: cameraController.cameraLayer,
            image: image,
            results: results,
            on: cameraController.view
        )
    }
}

extension ViewController: BoxServiceDelegate {
    func boxService(_ service: BoxService, didDetect images: [UIImage]) {
        guard let biggestImage = images.sorted(by: {
            $0.size.width > $1.size.width && $0.size.height > $1.size.height
        }).first else {
            return
        }
//        print(biggestImage.size)
        findTextArea.handle(image: biggestImage)
    }
}

extension ViewController: FindTextAreaDelegate {
    func findTextArea(_ version: FindTextArea, didDetect image: UIImage, namecard: UIImage, results: [VNTextObservation]) {
//        print(results)
        processRecognize.handle(cameraLayer: cameraController.cameraLayer,
                                image: image,
                                nameCard: namecard,
                                results: results,
                                on: cameraController.view)
    }
}

extension ViewController: ProcessRecognizeDelegate {
    func processRecognize(_ service: ProcessRecognize, textDetect text: [String], full nameCard: UIImage) {
        stopIndicator()
        removeBlurEffect()
        hideCameraView()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let resultController = storyBoard.instantiateViewController(withIdentifier: "ShowResult")
        self.present(resultController, animated: true, completion: {
            (resultController as? ResultViewController)?.handle(predictText: text, nameCard: nameCard)
        })
    }
}

