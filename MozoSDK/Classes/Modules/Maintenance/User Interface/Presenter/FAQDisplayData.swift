//
//  FAQDisplayData.swift
//  MozoSDK
//
//  Created by Hoang Nguyen on 5/16/19.
//

import Foundation
class FAQDisplayData {
    let displayItems = DisplayUtils.appType == .Shopper ? FAQDisplayData.allItemsShopper() : FAQDisplayData.allItemsRetailer()
    
    func randomItem() -> FAQDisplayItem {
        return displayItems.randomElement() ?? displayItems[0]
    }
    
    static func allItemsShopper() -> [FAQDisplayItem] {
        let helpCenterPath = DisplayUtils.getHelpCenterPath()
        let item1 = FAQDisplayItem(id: 1, title: "What are MozoX Tokens? What are MozoX Tokens used for?", answer: "MozoX Tokens are digital utility tokens that can be used by merchants to reward customers for visiting their venues. Customers can collect MozoX Tokens and redeem them for discounts on products and services as determined by each merchant.", link: "/retailer(\(helpCenterPath))/#retailer-faq-about-2")
        
        let item2 = FAQDisplayItem(id: 2, title: "How can I earn MozoX ?", answer: "MozoX App provides functions so that allow you to discover airdrop events using a map view or a list view, search... Check the airdrop date and time and then go to store during those dates and times to receive MozoX. DO NOT forget to turn on bluetooth when you enter the store", link: "/#home-faq-10")
        
        let item3 = FAQDisplayItem(id: 3, title: "How can I send MozoX as a gift to my friends?", answer: "On the wallet screen, using the feature \"Send MozoX\" to send MozoX to your friend's wallet.\nBest practise:\n- If your friend is with you, you can simply scan QR code address on his wallet screen. Remember to save your friend 's address to your MozoX address book for later use.", link: "/#home-faq-shopper-3")
        
        let item4 = FAQDisplayItem(id: 4, title: "How long I have to wait to get the next airdrop from the same event of a store?", answer: "The store sets \"Airdrop Frequency\" for each event that they create. As you visit the store after that time, you will get the next airdrop. Its frequency is typically 1 day.", link: "/#home-faq-shopper-4")
        
        let item5 = FAQDisplayItem(id: 5, title: "Why do I need to turn on Bluetooth to get MozoX from airdrop events?", answer: "Each store in MozoX system has one or more beacons. When the users visit the store and turns on Bluetooth, the beacon will interact with MozoX application via Bluetooth, so you can get airdrop automatically from the system.", link: "/#home-faq-shopper-5")
        
        return [item1, item2, item3, item4, item5]
    }
    
    static func allItemsRetailer() -> [FAQDisplayItem] {
        let helpCenterPath = DisplayUtils.getHelpCenterPath()
        let item1 = FAQDisplayItem(id: 1, title: "What are MozoX Tokens? What are MozoX Tokens used for?", answer: "MozoX Tokens are digital utility tokens that can be used by merchants to reward customers for visiting their venues. Customers can collect MozoX Tokens and redeem them for discounts on products and services as determined by each merchant.", link: "/retailer(\(helpCenterPath))/#retailer-faq-about-2")
        
        let item2 = FAQDisplayItem(id: 2, title: "How can I attract customers with MozoX?", answer: "By offering MozoX Tokens for visiting your venue, customers will have an incentive to come there and, by offering discounts through a redemption program, you are ensured that customers will want to keep collecting MozoX Tokens.", link: "/retailer(\(helpCenterPath))/#retailer-faq-about-2")
        
        let item3 = FAQDisplayItem(id: 3, title: "What is the difference between MozoX and other types of advertising?", answer: "With MozoX, you only reward customers when they physically enter your venue, so there is a 1:1 correlation between advertising monies spent and customers at your venue. Other advertising channels do not offer any guarantees that their clicks or banners will result in customers in your venue.", link: "/retailer(\(helpCenterPath))#retailer-faq-about-5")
        
        let item4 = FAQDisplayItem(id: 4, title: "How do MozoX Tokens work as a rewards program using blockchain technology?", answer: "Customers will accumulate enough reward tokens aka MozoX to redeem them for deals, discounts and promotions in the rewards program. So these customers now have an incentive to go to where retailers and venue operators are set up airdrop events. By applying blockchain technology, MozoX is more secure and convenient than any traditional loyalty applications. Furthermore, by incorporating with location based service technology, MozoX ensures that user really physically enter the venue.\nRetailers and venue operators use MozoX Retailer App to set up airdrop events through the use of a beacon, a specific location detector, that requires the users must be in range of the beacon inorder to receive MozoX. This will help Retailers and venue operators control their foot traffic. Additionally, using MozoX Retailer App, Retailers and venue operators can set up their deals, discounts and promotions.\nCustomers use MozoX App to browse, search, discover airdrop events, deals, discounts and promotions offered by both Retailer and venu operator.\nMozoX App(s) also help Retailers/venue operators and customers consummates the deals, discounts and promotions in effective and efficient way.", link: "/#home-faq-11")
        
        let item5 = FAQDisplayItem(id: 5, title: "What are hashtags? Why do I need to choose them?", answer: "Hashtags are a words or phrases preceded by a hash sign (#). On MozoX, hashtags are used to help identify your venue according to the description you want customers to discover you by.", link: "/retailer(\(helpCenterPath))#retailer-faq-register-3")
        
        let item6 = FAQDisplayItem(id: 6, title: "Can I get back MozoX Tokens after setting up an airdrop event?", answer: "One you have finalized and saved an airdrop event, you cannot retrieve the MozoX Tokens set aside for the event. If the airdrop event status is \"Scheduled\" or \"Active\" you are obligated to use the MozoX tokens for the duration of the event.  Once the event status is \"Ended\", you can retrieve any MozoX Tokens that have not been airdropped to customers.", link: "/retailer(\(helpCenterPath))#retailer-faq-settings-4")
        
        let item7 = FAQDisplayItem(id: 7, title: "Can I share Administrator rights with another manager at my store?", answer: "We do not recommend sharing Administrator rights with your employees. MozoX Retailer App allows for sub-accounts which grant permissions similar to the Administrator, except that they are not able to edit store information, beacon or sub-accounts. Please note that the sub-account wallet is set to zero when the sub-account is created. The Administrator will need to transfer MozoX Tokens to a sub-account in order for the sub-account holder to create airdrop events..", link: "/retailer(\(helpCenterPath))#retailer-faq-usage-2")
        
        let item8 = FAQDisplayItem(id: 8, title: "When will MozoX tokens airdrop to my customers?", answer: "If customers walk into beacon range of your store during the time the airdrop event is happening, they will receive MozoX tokens.", link: "/retailer(\(helpCenterPath))#retailer-faq-usage-3")
        
        return [item1, item2, item3, item4, item5, item6, item7, item8]
    }
}
