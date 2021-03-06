//
//  UILabel+Extension.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 9/14/18.
//

import UIKit

public extension UILabel {
    
    /**
     This function adding image with text on label.
     
     - parameter text: The text to add
     - parameter image: The image to add
     - parameter imageBehindText: A boolean value that indicate if the imaga is behind text or not
     - parameter keepPreviousText: A boolean value that indicate if the function keep the actual text or not
     */
    func addTextWithImage(text: String, image: UIImage, imageBehindText: Bool, keepPreviousText: Bool) {
        let lAttachment = NSTextAttachment()
        lAttachment.image = image
        
        // 1pt = 1.32px
        let lFontSize = round(self.font.pointSize * 1.32)
        let lRatio = image.size.width / image.size.height
        if imageBehindText {
            lAttachment.bounds = CGRect(x: 0, y: 3, width: 6, height: 6)
        } else {
            lAttachment.bounds = CGRect(x: 0, y: ((self.font.capHeight - lFontSize) / 2).rounded(), width: lRatio * lFontSize, height: lFontSize)
        }
        
        let lAttachmentString = NSAttributedString(attachment: lAttachment)
        
        if imageBehindText {
            let lStrLabelText: NSMutableAttributedString
            
            if keepPreviousText, let lCurrentAttributedString = self.attributedText {
                lStrLabelText = NSMutableAttributedString(attributedString: lCurrentAttributedString)
                lStrLabelText.append(NSMutableAttributedString(string: text))
            } else {
                lStrLabelText = NSMutableAttributedString(string: text)
            }
            
            lStrLabelText.append(lAttachmentString)
            self.attributedText = lStrLabelText
        } else {
            let lStrLabelText: NSMutableAttributedString
            
            if keepPreviousText, let lCurrentAttributedString = self.attributedText {
                lStrLabelText = NSMutableAttributedString(attributedString: lCurrentAttributedString)
                lStrLabelText.append(NSMutableAttributedString(attributedString: lAttachmentString))
                lStrLabelText.append(NSMutableAttributedString(string: text))
            } else {
                lStrLabelText = NSMutableAttributedString(attributedString: lAttachmentString)
                lStrLabelText.append(NSMutableAttributedString(string: text))
            }
            
            self.attributedText = lStrLabelText
        }
    }
    
    /**
     This function adding text with different color on label after current text.
     
     - parameter text: The text to add
     - parameter color: The color of the text
     */
    func addTextWithColor(text: String, color: UIColor) {
        let lStrLabelText: NSMutableAttributedString
        let finalText = (self.text ?? "") + text
        let finalStr = NSAttributedString(string: finalText)
        lStrLabelText = NSMutableAttributedString(attributedString: finalStr)
        let range = NSRange(location: (self.text?.count)!, length: text.count)
        
        lStrLabelText.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        
        self.attributedText = lStrLabelText
    }
    
    func removeImage() {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
    /**
     This function adding image before adding text on label.
     
     - parameter text: The text to add
     - parameter image: The image to add
     */
    func addImageBeforeText(text: NSMutableAttributedString, image: UIImage, imageSize: CGSize = CGSize(width: 18, height: 16), imageTintColor: UIColor? = nil, x: CGFloat = 0, y: CGFloat = -3) {
        let lAttachment = NSTextAttachment()
        lAttachment.image = image
        
        lAttachment.bounds = CGRect(x: x, y: y, width: imageSize.width, height: imageSize.height)
        
        let lAttachmentString = NSAttributedString(attachment: lAttachment)
        
        let lStrLabelText = NSMutableAttributedString(attributedString: lAttachmentString)
        lStrLabelText.append(NSMutableAttributedString(string: " "))
        lStrLabelText.append(text)
        
        if let color = imageTintColor {
            lStrLabelText.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color,
                range: NSMakeRange(0, lAttachmentString.length))
        }
        
        self.attributedText = lStrLabelText
    }
    
    func setTextWithShadow(text: String, shadowColor: UIColor = UIColor(hexString: "80000000")) -> NSMutableAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = shadowColor
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = CGSize(width: 0.0, height: 1.0)
        let mAttributedText = NSMutableAttributedString(string: text, attributes: [
                NSAttributedString.Key.shadow: shadow
            ]
        )
        
        attributedText = mAttributedText
        return mAttributedText
    }
}
