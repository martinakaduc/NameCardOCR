//
//  ResultViewController+Extensions.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/30/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import Foundation

extension UIImageView {
}

extension ResultViewController {
    
    func saveImage(image: UIImage?) {
        guard let selectedImage = image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            alertDisplay(title: "Save error", message: error.localizedDescription)
        } else {
            alertDisplay(title: "Success", message: "We have successfully save your name card 's image.")
        }
    }
    
    func predictValue(inputString: [String], pattern: [String: String]) -> [String: [String]] {
        var contactPredict: [String: [String]] = [String: [String]]()
        var baseString: [String] = inputString
        pattern.keys.forEach { key in
            let regex = try! NSRegularExpression(pattern: pattern[key]!, options: [.caseInsensitive])
            var keyData: [String] = [String]()
            for i in 0..<baseString.count {
                if (regex.firstMatch(in: baseString[i], options:[], range: NSMakeRange(0, baseString[i].count)) != nil) {
                    keyData.append(baseString[i])
                }
            }
            keyData.append("")
            
            contactPredict[key] = keyData
        }
        // Add--None--
        // process prefix
        return contactPredict
    }
}


struct Name {
    let first: String
    let last: String
    
    init(first: String, last: String) {
        self.first = first
        self.last = last
    }
}

extension Name {
    init(fullName: String) {
        var names = fullName.components(separatedBy: " ")
        let first = names.removeFirst()
        let last = names.joined(separator: " ")
        self.init(first: first, last: last)
    }
}

extension Name: CustomStringConvertible {
    var description: String { return "\(first) \(last)" }
}

extension String {
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }
}
