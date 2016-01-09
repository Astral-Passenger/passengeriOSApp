//
//  HexToUIColor.swift
//  Passenger
//
//  Created by Connor Myers on 12/23/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation

class HexToUIColor {
    
    init() {
        
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        let cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}