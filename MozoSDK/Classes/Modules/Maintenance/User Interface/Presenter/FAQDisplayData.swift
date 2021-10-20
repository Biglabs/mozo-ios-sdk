//
//  FAQDisplayData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/16/19.
//

import Foundation
class FAQDisplayData {
    let displayItems = MozoSDK.appType == .Shopper ? FAQDisplayData.allItemsShopper() : FAQDisplayData.allItemsRetailer()
    
    func randomItem() -> FAQDisplayItem {
        return displayItems.randomElement() ?? displayItems[0]
    }
    
    static func allItemsShopper() -> [FAQDisplayItem] {
        let helpCenterPath = DisplayUtils.getHelpCenterPath()
        return [
            FAQDisplayItem(id: 1, title: "faq_shopper_1_title", answer: "faq_shopper_1_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-about-2"),
            FAQDisplayItem(id: 2, title: "faq_shopper_2_title", answer: "faq_shopper_2_answer", link: "\(helpCenterPath)&section=faq-shopper#home-faq-10"),
            FAQDisplayItem(id: 3, title: "faq_shopper_3_title", answer: "faq_shopper_3_answer", link: "\(helpCenterPath)&section=faq-shopper#home-faq-shopper-3"),
            FAQDisplayItem(id: 4, title: "faq_shopper_4_title", answer: "faq_shopper_4_answer", link: "\(helpCenterPath)&section=faq-shopper#home-faq-shopper-4"),
            FAQDisplayItem(id: 5, title: "faq_shopper_5_title", answer: "faq_shopper_5_answer", link: "\(helpCenterPath)&section=faq-shopper#home-faq-shopper-5"),
            FAQDisplayItem(id: 6, title: "faq_shopper_6_title", answer: "faq_shopper_6_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-1"),
            FAQDisplayItem(id: 7, title: "faq_shopper_7_title", answer: "faq_shopper_7_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-3"),
            FAQDisplayItem(id: 8, title: "faq_shopper_8_title", answer: "faq_shopper_8_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-4")
        ]
    }
    
    static func allItemsRetailer() -> [FAQDisplayItem] {
        let helpCenterPath = DisplayUtils.getHelpCenterPath()
        return [
            FAQDisplayItem(id: 1, title: "faq_retailer_1_title", answer: "faq_retailer_1_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-about-2"),
            FAQDisplayItem(id: 2, title: "faq_retailer_2_title", answer: "faq_retailer_2_answer", link: "\(helpCenterPath)&section=faq-retailer#home-faq-11"),
            FAQDisplayItem(id: 3, title: "faq_retailer_3_title", answer: "faq_retailer_3_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-about-3"),
            FAQDisplayItem(id: 4, title: "faq_retailer_4_title", answer: "faq_retailer_4_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-about-4"),
            FAQDisplayItem(id: 5, title: "faq_retailer_5_title", answer: "faq_retailer_5_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-about-5"),
            FAQDisplayItem(id: 6, title: "faq_retailer_6_title", answer: "faq_retailer_6_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-register-3"),
            FAQDisplayItem(id: 7, title: "faq_retailer_7_title", answer: "faq_retailer_7_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-settings-1"),
            FAQDisplayItem(id: 8, title: "faq_retailer_8_title", answer: "faq_retailer_8_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-settings-2"),
            FAQDisplayItem(id: 9, title: "faq_retailer_9_title", answer: "faq_retailer_9_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-settings-4"),
            FAQDisplayItem(id: 10, title: "faq_retailer_10_title", answer: "faq_retailer_10_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-settings-5"),
            FAQDisplayItem(id: 11, title: "faq_retailer_11_title", answer: "faq_retailer_11_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-usage-1"),
            FAQDisplayItem(id: 12, title: "faq_retailer_12_title", answer: "faq_retailer_12_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-usage-2"),
            FAQDisplayItem(id: 13, title: "faq_retailer_13_title", answer: "faq_retailer_13_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-usage-3"),
            FAQDisplayItem(id: 14, title: "faq_retailer_14_title", answer: "faq_retailer_14_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-usage-4"),
            FAQDisplayItem(id: 15, title: "faq_retailer_15_title", answer: "faq_retailer_15_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-1"),
            FAQDisplayItem(id: 16, title: "faq_retailer_16_title", answer: "faq_retailer_16_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-3"),
            FAQDisplayItem(id: 17, title: "faq_retailer_17_title", answer: "faq_retailer_17_answer", link: "\(helpCenterPath)&section=faq-retailer#retailer-faq-support-4"),
            FAQDisplayItem(id: 18, title: "faq_retailer_18_title", answer: "faq_retailer_18_answer", link: "\(helpCenterPath)&section=faq-retailer#how-to-buy-mozoX")
        ]
    }
}
