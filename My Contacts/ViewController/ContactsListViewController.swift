//
//  ContactsListViewController.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import UIKit

class ContactListCell : UITableViewCell
{
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    
    var link: ContactsListViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let favoriteBtn = UIButton()
        favoriteBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        favoriteBtn.setImage(UIImage(named: "home_favourite"), for: .normal)
        accessoryView = favoriteBtn
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ContactsListViewController: UIViewController {

    @IBOutlet weak var contactsList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
