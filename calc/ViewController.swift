//
//  ViewController.swift
//  calc
//
//  Created by macbook pro on 11/30/19.
//  Copyright © 2019 macbook pro. All rights reserved.
//


import UIKit
import AVFoundation
import Firebase

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var videoPreview: UIView!
    
    var settings: AVCapturePhotoSettings!
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput? //the AVCapturePhotoOutput class instead. Th
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    //stillImageOutput.capturePhoto(with: settings, delegate: self)
    
    @IBAction func snap(_ sender: Any) {
        settings = AVCapturePhotoSettings()
        settings.livePhotoVideoCodecType = .jpeg
        stillImageOutput!.capturePhoto(with: settings, delegate: self)
        
    }
    
    func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
        ) -> VisionDetectorImageOrientation {
        switch deviceOrientation {
        case .portrait:
            return cameraPosition == .front ? .leftTop : .rightTop
        case .landscapeLeft:
            return cameraPosition == .front ? .bottomLeft : .topLeft
        case .portraitUpsideDown:
            return cameraPosition == .front ? .rightBottom : .leftBottom
        case .landscapeRight:
            return cameraPosition == .front ? .topRight : .bottomRight
        case .faceDown, .faceUp, .unknown:
            return .leftTop
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        if let data = imageData, let img = UIImage(data: data) {
            print(img)
            let vision = Vision.vision()
            let textRecognizer = vision.onDeviceTextRecognizer()
            let vimage = VisionImage(image: img)
            let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
            let metadata = VisionImageMetadata()
            metadata.orientation = imageOrientation(
                deviceOrientation: UIDevice.current.orientation,
                cameraPosition: cameraPosition
            )
            vimage.metadata = metadata
            
            textRecognizer.process(vimage) { result, error in
              guard error == nil, let result = result else {
                // ...
                print(error?.localizedDescription)

                return
              }
              // Recognized text
                print("----"+result.text)
            }
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        let backCamera =  AVCaptureDevice.default(for: AVMediaType.video)
       var error: NSError?
       var input: AVCaptureDeviceInput!
       do {
        input = try AVCaptureDeviceInput(device: backCamera!)
       } catch let error1 as NSError {
         error = error1
         input = nil
         print(error!.localizedDescription)
       }
       if error == nil && session!.canAddInput(input) {
         session!.addInput(input)
         stillImageOutput = AVCapturePhotoOutput()
         settings = AVCapturePhotoSettings()
         settings.livePhotoVideoCodecType = .jpeg
         

        if session!.canAddOutput(stillImageOutput!) {
            session!.addOutput(stillImageOutput!)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
            videoPreviewLayer!.videoGravity =    AVLayerVideoGravity.resizeAspect
            videoPreviewLayer!.connection?.videoOrientation =   AVCaptureVideoOrientation.portrait
           videoPreview.layer.addSublayer(videoPreviewLayer!)
           session!.startRunning()
        }
      }
     }
    
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       videoPreviewLayer!.frame = videoPreview.bounds
    }




    
    
    

}

