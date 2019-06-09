//
//  ContactsListViewController.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import UIKit
import Kingfisher

class ContactListCell : UITableViewCell
{
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    
    var link: ContactsListViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let favoriteBtn = UIButton()
        favoriteBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        favoriteBtn.setImage(UIImage(named: "home_favourite"), for: .normal)
        accessoryView = favoriteBtn
        accessoryView?.isHidden = true
    }

    func setData(contact_img : String, contact_name : String,isFavourite : Bool)
    {
        contactName.text = contact_name
        accessoryView?.isHidden = isFavourite == true ? false : true
        let imgUrl = Constants.baseUrl.appending(contact_img)
        guard let contactUrl = URL(string: imgUrl) else {return}
        contactImage.kf.setImage(with: contactUrl)
    }
}


class ContactsListViewController: UIViewController {

    @IBOutlet weak var contactsList: UITableView!
    
    var networkManager: NetworkManager!
    var loader = UIView()
    var contactsDictionary = [String : [ContactsAPIResponse]]()
    var contactTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setViews()
        getContacts()
    }
    func setViews()
    {
        contactsList.sectionIndexColor = UIColor(displayP3Red: 80/255, green: 227/255, blue: 194/255, alpha: 1)
        loader = UIUtils.createLoader(vc: self)
        self.view.addSubview(loader)
        self.loader.isHidden = true
    }
    
    func getContacts()
    {
        loader.isHidden = false
        networkManager = NetworkManager()
       
        networkManager.getContacts(){ data,error in
            if error == nil {
                self.parseData(data)
            }
            else {
                UIUtils().show_Alert(self, title_string: "Error", message_string: error ?? "")
            }
        }
    }
    func parseData(_ data : Data?)
    {
        if data != nil
        {
            do {
                let apiResponse = try JSONDecoder().decode([ContactsAPIResponse].self, from: data!)
                self.contactsDictionary = Dictionary(grouping: apiResponse, by: { (element: ContactsAPIResponse) in
                    let letter = Character(String((element.firstName ?? "").prefix(1).uppercased()))
                    if letter.ascii! < UInt32(65) || letter.ascii! >  UInt32(90)
                    {
                        return "#"
                    }
                    return (element.firstName ?? "").prefix(1).uppercased()
                })
                self.contactTitles = Array(contactsDictionary.keys).sorted(by : <)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.loader.isHidden = true
                    self.contactsList.reloadData()
                }
            }catch {
                UIUtils().show_Alert(self, title_string: "Error", message_string: error.localizedDescription)
                print(error)
            }
        }
    }
    
    @IBAction func addNewContact(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createContact")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension ContactsListViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
        uiview.backgroundColor = UIColor(displayP3Red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width - 30, height: 35))
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.text = self.contactTitles[section]
        uiview.addSubview(label)
        return uiview
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.contactTitles
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.contactTitles[section]
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactsDictionary[self.contactTitles[section]]?.count ?? 0
    }
    
}
extension ContactsListViewController : UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactTitles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact_cell", for: indexPath) as! ContactListCell
        let sectionItems = self.contactsDictionary[self.contactTitles[indexPath.section]]
        
        cell.setData(contact_img: sectionItems?[indexPath.row].profilePic ?? "", contact_name: (sectionItems?[indexPath.row].firstName ?? "") + " " + (sectionItems?[indexPath.row].lastName ?? ""), isFavourite: sectionItems?[indexPath.row].favorite ?? false)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionItems = self.contactsDictionary[self.contactTitles[indexPath.section]]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetails") as! ContactDetailViewController
        vc.contactId = sectionItems?[indexPath.row].id ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
