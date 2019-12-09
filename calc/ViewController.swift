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


    var videoPreview: UIView!
    var resTextView: UILabel!

    var settings: AVCapturePhotoSettings!
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput? //the AVCapturePhotoOutput class instead. Th
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var computation: Int?
    
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
    
    func updateRes(res: Int){
        DispatchQueue.main.async {

                        self.resTextView.text = String(res)
                        self.view.setNeedsDisplay()
                        self.resTextView.setNeedsDisplay()
                        self.resTextView.layoutIfNeeded()
                        
                        self.resTextView.sizeToFit()

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
                let str = result.text
                
                print(str)
                
                if str.count == 3{
                    if let left = Int(str[0]), let right = Int(str[2]){
                        switch str[1] {
                            case "+":
                                let res = left + right
                                self.updateRes(res: res)

                            case "-":
                                let res = left - right
                                self.updateRes(res: res)
                            case "/":
                                let res = left / right
                                self.updateRes(res: res)
                            case "x":
                                let res = left * right
                                self.updateRes(res: res)

                            default:
                                self.resTextView.text = "fail"

                            }
                        }
                }
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
            videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            session!.startRunning()
        }
      }
     }
    
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        videoPreview = UIView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height/2.5))
        resTextView = UILabel()
        resTextView.center = CGPoint(x: self.view.frame.width/2 - 10, y: 500)
        resTextView.text = " "

        resTextView.font = UIFont.systemFont(ofSize: 36)

        resTextView.textColor = UIColor.black
        resTextView.sizeToFit()

        self.view.addSubview(videoPreview)
        self.view.addSubview(resTextView)

        videoPreview.backgroundColor = UIColor.red
        videoPreview.layer.addSublayer(videoPreviewLayer!)
        videoPreviewLayer!.frame = videoPreview.bounds
    }




    
    
    

}


extension String {

  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}
