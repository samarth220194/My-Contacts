//
//  ContactsListViewController.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import Reachability

class ContactListCell : UITableViewCell
{
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let favoriteBtn = UIButton()
        contactImage.addCornerRadius(radius: self.contactImage.frame.width/2)
        favoriteBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        favoriteBtn.setImage(UIImage(named: "home_favourite"), for: .normal)
        accessoryView = favoriteBtn
        accessoryView?.isHidden = true
    }
    func setData(contact_img : String, contact_name : String,isFavourite : Bool)
    {
        contactName.text = contact_name
        accessoryView?.isHidden = isFavourite == true ? false : true
        guard let contactUrl = URL(string: contact_img) else {return}
        
        if contactUrl.absoluteString.contains("http")
        {
            if UIApplication.shared.canOpenURL(contactUrl)
            {
                contactImage.kf.setImage(with: contactUrl, placeholder: UIImage(named: "placeholder_photo")){
                    result in
                    switch result {
                    case .success( _) :
                        print("success image loading")
                    case .failure( _):
                        print("error loading image")
                    }
                }
            }
            else
            {
                print("invalid image url")
            }
        }
        else
        {
            let url = URL(fileURLWithPath: Utils().getImageUrl(imageName: contact_img) ?? "")
            let provider = LocalFileImageDataProvider(fileURL: url)
            self.contactImage.kf.setImage(with: provider,placeholder: UIImage(named: "placeholder_photo"))
        }
       
    }
}

class ContactsListViewController: UIViewController {
    
    @IBOutlet weak var contactsList: UITableView!
    @IBOutlet weak var syncView: UIView!
    @IBOutlet weak var syncViewHt: NSLayoutConstraint!
    
    var networkManager: NetworkManager!
    var coreDataStack : CoreDataStack!
    var contacts : [Contact] = [] // To fetch all contacts from database
    var loader = UIView() // Loader for API
    var contactsDictionary = [String : [ContactsAPIResponse]]() // To group the api response into dictionary
    var contactTitles = [String]() // Array for  header of all the sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager = NetworkManager()
        coreDataStack = CoreDataStack(modelName: "My_Contacts")
        setViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // first fetch the offline contacts and in completion of that get contacts from server

        coreDataStack.fetchAllContacts() { contacts in
            self.contacts = contacts ?? []
            self.getContactsFromServer()
            self.coreDataStack.fetchUnsysncContacts(){ unsyncContacts in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    if unsyncContacts?.count != 0
                    {
                        self.syncView.isHidden = false
                        self.syncViewHt.constant = 45
                        self.syncContacts(contacts : unsyncContacts ?? [],index : 0)
                    }
                    else
                    {
                        self.syncView.isHidden = true
                        self.syncViewHt.constant = 0
                    }
                }
            }
        }
    }

    func getContactsFromServer()
    {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.loader.isHidden = false
        }
        networkManager.getContacts(){ data,error in
            if error == nil {
                self.parseData(data)
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.loader.isHidden = true
                    self.getOfflineContacts(contacts: self.contacts)
                }
            }
        }
    }
    func parseData(_ data : Data?)
    {
        if data != nil
        {
            do {
                let apiResponse = try JSONDecoder().decode([ContactsAPIResponse].self, from: data!)
                if self.contacts.count < apiResponse.count // means local Db contacts are less than contacts from server
                {
                    self.getSectionedData(contacts: apiResponse)
                    self.saveContacts(contactList : apiResponse)
                }
                else
                {
                    self.getOfflineContacts(contacts: self.contacts)
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.loader.isHidden = true
                    self.contactsList.reloadData()
                }
            }catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.getOfflineContacts(contacts: self.contacts)
                }
                print(error)
            }
        }
        else
        {
            self.getOfflineContacts(contacts: self.contacts)
        }
    }
    
    func syncContacts(contacts : [Contact],index : Int)
    {
        // Recursively syncing the contacts with server
        if index == contacts.count
        {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.syncView.isHidden = true
                self.syncViewHt.constant = 0
            }
        }
        else
        {
            let postBody = ["first_name" : (contacts[index].value(forKey: "first_name") as? String) ?? "",
                            "last_name" : (contacts[index].value(forKey: "last_name") as? String) ?? "",
                            "email" :  (contacts[index].value(forKey: "email") as? String) ?? "",
                            "phone_number" : (contacts[index].value(forKey: "phone_number") as? String) ?? "",
                            "favorite" : (contacts[index].value(forKey: "favorite") as? Bool) ?? false,
                            "profile_pic" : (contacts[index].value(forKey: "profile_pic") as? String) ?? ""] as [String : Any]
            
            if (contacts[index].value(forKey: "contactId") as? Int ?? 0) >= 0   // update Contact (PUT api)
            {
                print(postBody)
                networkManager.updateContact(body: postBody,id : (contacts[index].value(forKey: "contactId") as? Int) ?? 0){ data,error in
                    if error == nil {
                        self.parseData(data) { contactResponse in
                            if contactResponse != nil
                            {
                                self.coreDataStack.syncContact(oldId: Int(contacts[index].contactId), newId: contactResponse?.id ?? 0)
                                self.syncContacts(contacts: contacts, index: index + 1)
                            }
                            else
                            {
                                self.syncContacts(contacts: contacts, index: index + 1)
                            }
                        }
                    }
                    else
                    {
                        self.syncContacts(contacts: contacts, index: index + 1)
                    }
                }
            }
            else  // create Contact (POST api)
            {
                networkManager.createContact(body: postBody){ data,error in
                    if error == nil {
                        self.parseData(data) { contactResponse in
                            if contactResponse != nil
                            {
                                self.coreDataStack.syncContact(oldId: Int(contacts[index].contactId), newId: contactResponse?.id ?? 0)
                                self.syncContacts(contacts: contacts, index: index + 1)
                            }
                            else
                            {
                                self.syncContacts(contacts: contacts, index: index + 1)
                            }
                        }
                    }
                    else
                    {
                        self.syncContacts(contacts: contacts, index: index + 1)
                    }
                }
            }
        }
    }
    func parseData(_ data : Data?, _ completion : @escaping (ContactsAPIResponse?) -> ())
    {
        if data != nil
        {
            do {
                let apiResponse = try JSONDecoder().decode(ContactsAPIResponse.self, from: data!)
                completion(apiResponse)
            }catch {
                completion(nil)
                print(error)
            }
        }
        else
        {
            completion(nil)
        }
    }
    
    func setViews()
    {
        contactsList.tableFooterView = UIView()
        contactsList.sectionIndexColor = UIColor(displayP3Red: 80/255, green: 227/255, blue: 194/255, alpha: 1)
        loader = UIUtils.createLoader(vc: self)
        self.view.addSubview(loader)
        self.loader.isHidden = true
    }
    func getSectionedData(contacts : [ContactsAPIResponse])
    {
        // grouping the api response into a dictionary (Eg. : ["A" :["Amit","Akshay","Anil"],"B" : ["Bat","Ball","Booo"]])
        let sortedContacts = contacts.sorted(by: {(c1 : ContactsAPIResponse,c2 : ContactsAPIResponse) -> Bool in
            return (c1.firstName ?? "").localizedCaseInsensitiveCompare(c2.firstName ?? "") == ComparisonResult.orderedAscending
        })
        self.contactsDictionary = Dictionary(grouping: sortedContacts, by: { (element: ContactsAPIResponse) in
            let letter = Character(String((element.firstName ?? "").prefix(1).uppercased()))
            if letter.ascii! < UInt32(65) || letter.ascii! >  UInt32(90)
            {
                return "~" // (ascii value : 126)
            }
            return (element.firstName ?? "").prefix(1).uppercased()
        })
        self.contactTitles = Array(contactsDictionary.keys).sorted(by : <)
    }
    
    func saveContacts(contactList : [ContactsAPIResponse])
    {
        // insert the contacts in database for offline access
        let dispatchQueue = DispatchQueue(label: "SavingContactsQueue", qos: .background)
        dispatchQueue.async {
            self.coreDataStack.deleteAllContacts {
                    self.coreDataStack.insertAllContacts(contacts: contactList) {}
            }
        }
    }
    func getOfflineContacts(contacts : [Contact])
    {
        // fetching offline contacts and showing them
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.loader.isHidden = true
            print(self.contacts.count)
            var localContacts = [ContactsAPIResponse]()
            for contact in contacts
            {
                let local_contact = ContactsAPIResponse(id: contact.value(forKey: "contactId") as? Int, firstName: contact.value(forKey: "first_name") as! String, lastName: contact.value(forKey: "last_name") as! String, profilePic: contact.value(forKey: "profile_pic") as! String, favorite: contact.value(forKey: "favorite") as! Bool, url: "", email: contact.value(forKey: "email") as! String, phoneNumber: contact.value(forKey: "phone_number") as! String, createdAt: "", updatedAt: "")
                localContacts.append(local_contact)
            }
            self.getSectionedData(contacts: localContacts)
            self.contactsList.reloadData()
        }
    }
    
    @IBAction func addNewContact(_ sender: Any) {
        // Navigate to add new contact
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
