//
//  ScannerViewController.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/19/18.
//

import Foundation
import AVFoundation
import UIKit
public protocol ScannerViewControllerDelegate {
    func didReceiveValueFromScanner(_ value: String)
}
public class ScannerViewController: MozoBasicViewController, AVCaptureMetadataOutputObjectsDelegate {
    public var delegate: ScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        self.createBackButton()
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func createBackButton() {
        let bottomPadding: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        let bottomOffset: CGFloat = 50 + bottomPadding * 0.5
        
        let parentWidth: CGFloat = 130
        let parentHeight: CGFloat = 45
        
        let frame = CGRect(
            x: view.frame.size.width / 2 - parentWidth / 2,
            y: view.frame.size.height - bottomPadding - bottomOffset - parentHeight,
            width: parentWidth,
            height: parentHeight
        )
        let backView = UIView(frame: frame)
        backView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.4)
        backView.roundedCircle()
        
        let textWidth: CGFloat = 50
        let textPadding: CGFloat = 9
        
        let imageWidth: CGFloat = 22.8
        let imageHeight: CGFloat = 18
        let imageFrame = CGRect(x: parentWidth / 2 - (imageWidth + textPadding + textWidth) / 2, y: parentHeight / 2 - imageHeight / 2, width: imageWidth, height: imageHeight)
        let imageView = UIImageView(frame: imageFrame)
        imageView.image = UIImage(named: "ic_left_arrow_white", in: BundleManager.mozoBundle(), compatibleWith: nil)
        backView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: imageFrame.maxX + textPadding, y: imageFrame.minY, width: textWidth, height: imageHeight))
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.text = "Back".localized
        //        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        backView.addSubview(label)
        
        view.addSubview(backView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.back))
        tap.numberOfTapsRequired = 1
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tap)
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported".localized, message: "Your device does not support scanning a code from an item.\nPlease use a device with a camera.".localized, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            self.back()
        }))
        DispatchQueue.main.async {
             self.present(ac, animated: true, completion: nil)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        captureSession = nil
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            dismiss(animated: true) {
                self.delegate?.didReceiveValueFromScanner(stringValue)
            }
            return
        }
        
        back()
    }
    
    @objc func back() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
