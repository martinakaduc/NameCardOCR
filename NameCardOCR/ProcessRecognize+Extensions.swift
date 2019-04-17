//
//  ProcessRecognize+Extensions.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/30/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation

extension ProcessRecognize {
    func crop(image: UIImage, rect: CGRect) -> UIImage? {
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func postProcessText(text: [String]) -> [String]? {
        var textProcess: [String] = []
        text.forEach { textLine in
            textProcess.append(textLine.replacingOccurrences(of: "\n", with: ""))
        }
        for i in 0..<textProcess.count {
            var textTemp:[String] = textProcess[i].components(separatedBy: ": ")
            if (textTemp.count > 1) {
                textTemp.removeFirst()
                textProcess[i] = textTemp.joined(separator: "")
            }
        }
        return textProcess
    }
}
