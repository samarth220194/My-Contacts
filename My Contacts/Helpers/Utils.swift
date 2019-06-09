//
//  Utils.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


class UIUtils {
    
    static func createLoader(vc : UIViewController) -> UIView
    {
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width, height: vc.view.frame.height))
        uiview.backgroundColor = UIColor(displayP3Red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        let activity_indicator = UIActivityIndicatorView.init(style: .white)
        activity_indicator.color = .black
        uiview.addSubview(activity_indicator)
        activity_indicator.center = CGPoint(x: vc.view.frame.width / 2, y: vc.view.frame.height / 2)
        activity_indicator.startAnimating()
        return uiview
    }
    func show_Alert(_ view_controller : UIViewController,title_string : String, message_string : String)
    {
        let alert = UIAlertController(title: title_string, message: message_string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        view_controller.present(alert, animated: true, completion: nil)
    }
    
    func callRM(mobile : String)
    {
        guard let callUrl = URL(string: "tel://\(mobile)") else {return}
        UIApplication.shared.open(callUrl, options: [:], completionHandler: nil)
    }
}
class ValidationUtils{
   
    static func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}


