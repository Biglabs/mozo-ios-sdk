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
    
    private var bottomPadding: CGFloat = 0
    private var bottomOffset: CGFloat = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        bottomOffset = 50 + bottomPadding * 0.5
        
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
        
        let size = 260
        let screenWidth = self.view.frame.size.width
        let xPos = (screenWidth / CGFloat(2)) - CGFloat(size / 2)
        let yPos = (self.view.frame.size.height / CGFloat(2))  - bottomPadding - bottomOffset - CGFloat(size / 2)
        let scanRect = CGRect(
            x: Int(xPos),
            y: Int(yPos),
            width: size,
            height: size
        )

        let metadataOutput = AVCaptureMetadataOutput()
        let x = scanRect.origin.x/480
        let y = scanRect.origin.y/640
        let width = scanRect.width/480
        let height = scanRect.height/640
        metadataOutput.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
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

        /**
         * Draw non capture area
         */
        let pathBigRect = UIBezierPath(rect: view.layer.bounds)
        pathBigRect.append(UIBezierPath(rect: scanRect))
        pathBigRect.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = pathBigRect.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.4
        view.layer.addSublayer(fillLayer)

        self.createBackButton()

        captureSession.startRunning()
    }

    func createBackButton() {
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
        
        /**
         * Add Scan QR code as title
         */
        let titleMargin: CGFloat = 40
        let titleLabel = UILabel(frame: CGRect(x: titleMargin, y: 100, width: view.frame.size.width - titleMargin * 2, height: 30))
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = "Scan QR Code".localized
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
    }

    func failed() {
        self.createBackButton()
        
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
