//
//  Extensions.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation
import UIKit

extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension UIView
{
    func add_shadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func addBorder(width : CGFloat,color : UIColor)
    {
        self.layer.masksToBounds = true
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    func addCornerRadius(radius : CGFloat)
    {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
}
