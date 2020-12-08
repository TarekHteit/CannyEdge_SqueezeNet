//
//  UIImageExtension.swift
//  ImageProcessing
//
//  Created by Tarek on 12/7/20.
//

import UIKit
extension UIImage {
   
    func addExif(_ container: [String:Any]?) -> Data? {
        let imageData = self.jpegData(compressionQuality: 1.0)

        var source: CGImageSource? = nil
        if let data = imageData as CFData? {
              source = CGImageSourceCreateWithData(data, nil)
          }


        var UTI: CFString? = nil
        if let source = source {
            UTI = CGImageSourceGetType(source)
        }

        let dest_data = CFDataCreateMutable(nil, 0)

        var destination: CGImageDestination? = nil
        
        if  UTI != nil {
          destination = CGImageDestinationCreateWithData(dest_data!, UTI!, 1, nil)
        }

        if destination == nil {
            print("Error: Could not create image destination")
        }

        if let destination = destination, let source = source {
            CGImageDestinationAddImageFromSource(destination, source, 0, container! as CFDictionary)
        }
        
        var success = false
        if let destination = destination {
            success = CGImageDestinationFinalize(destination)
        }

        if !success {
            print("Error: Could not create data from image destination")
        }

        return dest_data as Data?

    }
}
