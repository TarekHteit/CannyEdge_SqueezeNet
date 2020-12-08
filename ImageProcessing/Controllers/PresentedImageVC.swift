//
//  PresentedImageVC.swift
//  ImageProcessing
//
//  Created by Tarek on 12/8/20.
//

import UIKit
import CoreLocation
import Vision
import CoreML

class PresentedImageVC: UIViewController, CLLocationManagerDelegate {
    
    var image:UIImage?
    var metadata:[String : Any]?
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: SqueezeNet().model)
            let request = VNCoreMLRequest(
            model: model) { [weak self] request, error in
                guard let self = self else {
                    return
                }
                self.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocationManager()
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image != nil {
            imageView.image = image
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(image.imageOrientation.rawValue)) else {
                return
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler =
                VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let classifications =
                request.results as? [VNClassificationObservation] {
                let topClassifications = classifications.prefix(2).map {
                    (confidence: $0.confidence, identifier: $0.identifier)
                }
                var id:String?
                if topClassifications.count > 0 {
                    id = topClassifications[0].identifier
                }

                if let metadata = self.metadata, let image = self.image {
                    let metadata = self.locationMetaData(metadata:metadata,classification:id ?? "")
                    self.imageToSavedCanny(image: image, metadata: metadata)
                }
            }
        }
    }
    
    @IBAction func saveWasPressed(_ sender: Any) {
        if let image = image {
            classifyImage(image)
        }
    }
    
    func setupVC(image:UIImage,metadata:[String : Any]){
        self.image = image
        self.metadata = metadata
    }
    
    func imageToSavedCanny(image:UIImage,metadata:[String:Any]) {
        let cannyImage = OpenCVWrapper.cannyEdgeImage(image) ?? UIImage()
        savePhotoToLibrary(withData: cannyImage.addExif(metadata) ?? Data()) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.showAlert("Successfully done")
                }
            }
        }
    }
    
    func locationMetaData(metadata: [String : Any],classification:String) -> [String:Any] {
        var properties = metadata
        let exifDictionary: [AnyHashable: Any] = [kCGImagePropertyExifUserComment:"\(classification)_\(userLocation.coordinate.longitude)_\(userLocation.coordinate.latitude)"]
        properties[kCGImagePropertyExifDictionary as String] = exifDictionary
        return properties
    }
    
    func loadLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
    }
    
}
