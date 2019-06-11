//
//  ContactDetailViewController.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import UIKit
import Kingfisher
import MessageUI

protocol UpdateDetailsDelegate {
    func getUpdatedDetail(contact : ContactsAPIResponse)
}

class ContactDetailViewController: UIViewController,UpdateDetailsDelegate {
    

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var mobileNum: UILabel!
    @IBOutlet weak var emailId: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var loader = UIView()
    var networkManager: NetworkManager!
    var contactId : Int?
    var contactDetail : ContactsAPIResponse?
    var isFavourite : Bool?
    var coreDataStack : CoreDataStack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataStack = CoreDataStack(modelName: "My_Contacts")
        customiseView()
        if (NetworkConnection.sharedInstance.reachability).connection != .none
        {
            getServerContactDetails()
        }
        else
        {
            getOfflineContactDetails()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func getUpdatedDetail(contact: ContactsAPIResponse) {
        setData(contact)
    }
    
    
    func customiseView()
    {
        loader = UIUtils.createLoader(vc: self)
        self.view.addSubview(loader)
        self.loader.isHidden = true
        contactImage.addCornerRadius(radius: contactImage.frame.width / 2)
        contactImage.addBorder(width: 4.0, color: .white)
    }
    func getServerContactDetails()
    {
        loader.isHidden = false
        networkManager = NetworkManager()
        networkManager.getContactDetails(id: contactId ?? 0){ data,error in
            if error == nil {
                self.parseData(data)
            }
            else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    UIUtils().show_Alert(self, title_string: "Error", message_string: error ?? "")
                }
            }
        }
    }
    func parseData(_ data : Data?)
    {
        if data != nil
        {
            do {
                let apiResponse = try JSONDecoder().decode(ContactsAPIResponse.self, from: data!)
                self.contactDetail = apiResponse
                self.updateContactDetail(contact: apiResponse)
                self.setData(apiResponse)
            }catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                     UIUtils().show_Alert(self, title_string: "Error", message_string: error.localizedDescription)
                }
                print(error)
            }
        }
    }
    
    func updateContactDetail(contact : ContactsAPIResponse)
    {
        coreDataStack.updateContact(id: contact.id ?? 0, firstName: contact.firstName ?? "", lastName: contact.lastName ?? "", emaild: contact.email ?? "", isFavorite: contact.favorite ?? false, phoneNum: contact.phoneNumber ?? "", profilePic: contact.profilePic ?? "", sync: true){ error in
            if error == nil
            {
                print("success")
            }
            else
            {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    UIUtils().show_Alert(self, title_string: "Error", message_string: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func getOfflineContactDetails()
    {
        coreDataStack.fetchContactDetail(id: self.contactId ?? 0) { contacts in
            if contacts?.count != 0
            {
                self.contactDetail = ContactsAPIResponse(id: contacts?[0].value(forKey: "contactId") as? Int, firstName: contacts?[0].value(forKey: "first_name") as! String, lastName: contacts?[0].value(forKey: "last_name") as! String, profilePic: contacts?[0].value(forKey: "profile_pic") as! String, favorite: contacts?[0].value(forKey: "favorite") as! Bool, url: "", email: contacts?[0].value(forKey: "email") as! String, phoneNumber: contacts?[0].value(forKey: "phone_number") as! String, createdAt: "", updatedAt: "")
                self.setData(self.contactDetail!)
            }
        }
        
    }
    func setData(_ contactDetail : ContactsAPIResponse)
    {
        self.contactDetail = contactDetail
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.loader.isHidden = true
            self.isFavourite = contactDetail.favorite ?? false
            self.mobileNum.text = contactDetail.phoneNumber ?? ""
            self.emailId.text = contactDetail.email ?? ""
            let btnImage = contactDetail.favorite == true ? UIImage(named: "favourite_button_selected") : UIImage(named: "favourite_button")
            self.favouriteButton.setImage(btnImage, for: .normal)
            self.contactName.text = (contactDetail.firstName ?? "") + " " + (contactDetail.lastName ?? "")
            if contactDetail.profilePic?.contains("http") ?? false
            {
                guard let contactUrl = URL(string: contactDetail.profilePic ?? "") else {return}
                if UIApplication.shared.canOpenURL(contactUrl)
                {
                    self.contactImage.kf.setImage(with: contactUrl,placeholder: UIImage(named: "placeholder_photo")){
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
                     print("error loading image")
                }
            }
            else
            {
                let url = URL(fileURLWithPath: Utils().getImageUrl(imageName: contactDetail.profilePic ?? "") ?? "")
                let provider = LocalFileImageDataProvider(fileURL: url)
                self.contactImage.kf.setImage(with: provider,placeholder: UIImage(named: "placeholder_photo"))
                
            }
        }
    }
    
    @IBAction func message(_ sender: Any) {
        if mobileNum.text != ""
        {
            sendMessage()
        }
        else
        {
            UIUtils().show_Alert(self, title_string: "Alert", message_string: "No recepients found")
        }
    }
    
    @IBAction func call(_ sender: Any) {
        if mobileNum.text != ""
        {
            UIUtils().callRM(mobile: mobileNum.text ?? "")
        }
        else
        {
             UIUtils().show_Alert(self, title_string: "Alert", message_string: "Invalid Contact")
        }
    }
    
    @IBAction func email(_ sender: Any) {
        if emailId.text != ""
        {
            emailUser()
        }
        else
        {
             UIUtils().show_Alert(self, title_string: "Alert", message_string: "No recepients found")
        }
    }
    
    @IBAction func markFavourite(_ sender: Any) {
        isFavourite = !isFavourite!
        let btnImage = isFavourite == true ? UIImage(named: "favourite_button_selected") : UIImage(named: "favourite_button")
        self.favouriteButton.setImage(btnImage, for: .normal)
        if self.contactDetail != nil
        {
            coreDataStack.updateContact(id: self.contactDetail?.id ?? 0, firstName: self.contactDetail?.firstName ?? "", lastName: self.contactDetail?.lastName ?? "", emaild: self.contactDetail?.email ?? "", isFavorite: isFavourite ?? false, phoneNum: self.contactDetail?.phoneNumber ?? "", profilePic: self.contactDetail?.profilePic ?? "" , sync: false) { error in
                if error == nil
                {
                    print("success")
                }
                else
                {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        UIUtils().show_Alert(self, title_string: "Error", message_string: error?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
    
    @IBAction func editContact(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createContact") as! CreateContactViewController
        vc.contactDetail = contactDetail
        vc.updateDetailDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func sendMessage()
    {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = [mobileNum.text ?? ""]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else
        {
            showSendMessageErrorAlert()
        }
    }
    func showSendMessageErrorAlert() {
        let sendMailAlert = UIAlertController(title: "Could Not Send message", message: "Your device could not send message.Please check message configuration and try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailAlert.addAction(action)
        self.present(sendMailAlert, animated: true, completion: nil)
    }
    
    
    func emailUser() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([emailId.text ?? ""])
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.Please check e-mail configuration and try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailAlert.addAction(action)
        self.present(sendMailAlert, animated: true, completion: nil)
    }
}
extension ContactDetailViewController : MFMailComposeViewControllerDelegate
{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
extension ContactDetailViewController : MFMessageComposeViewControllerDelegate
{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
