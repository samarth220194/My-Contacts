//
//  CreateContactViewController.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 09/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

class CreateContactViewController: UIViewController,UINavigationControllerDelegate {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var mobileNum: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var attachImage: UIButton!
    
    var loader = UIView()
    var contactDetail : ContactsAPIResponse?
    var networkManager: NetworkManager!
    var contactImageUrl : String? // for saving the picked image in this variable
    var coreDataStack : CoreDataStack!
    var updateDetailDelegate : UpdateDetailsDelegate? // for communicating between ContactDetail controller and ContactCreateController (to pass data)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        customiseView()
        coreDataStack = CoreDataStack(modelName: "My_Contacts")
        setData()
    }
    func setData()
    {
        if contactDetail != nil // means there is an update to contact details
        {
           firstName.text = contactDetail?.firstName ?? ""
           lastName.text = contactDetail?.lastName ?? ""
           emailId.text = contactDetail?.email ?? ""
           mobileNum.text = contactDetail?.phoneNumber ?? ""
           guard let contactUrl = URL(string: contactDetail?.profilePic ?? "") else {return}
            
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
                let url = URL(fileURLWithPath: Utils().getImageUrl(imageName: contactDetail?.profilePic ?? "") ?? "")
                let provider = LocalFileImageDataProvider(fileURL: url)
                self.contactImage.kf.setImage(with: provider,placeholder: UIImage(named: "placeholder_photo"))
                
            }
        }
    }
    func customiseView()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        loader = UIUtils.createLoader(vc: self)
        self.view.addSubview(loader)
        self.loader.isHidden = true
        contactImage.addCornerRadius(radius: contactImage.frame.width / 2)
        contactImage.addBorder(width: 4.0, color: .white)
        attachImage.addCornerRadius(radius: attachImage.frame.width / 2)
    }
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        let mediaType = AVMediaType.video
        AVCaptureDevice.requestAccess(for: mediaType, completionHandler: {
            (granted) in
            if granted == true {
                if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
                {
                    let imagePicker = UIImagePickerController()
                    imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    imagePicker.allowsEditing = false
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                let alert  = UIAlertController(title: "This app doesn't have access to camera.", message: "You can enable in Privacy Settings.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    func openGallary()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.isAccessibilityElement = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createUpdateContact(_ sender: Any) {
        self.view.endEditing(true)
        if firstName.text == "" || lastName.text == "" || mobileNum.text == "" || emailId.text == ""
        {
            UIUtils().show_Alert(self, title_string: "Alert", message_string: "Fill all the fields")
        }
        else if ValidationUtils.isValidMobile(mobile: mobileNum.text!) == false
        {
             UIUtils().show_Alert(self, title_string: "Alert", message_string: "Enter valid mobile number")
        }
        else if ValidationUtils.isValidEmail(email: emailId.text!) == false
        {
             UIUtils().show_Alert(self, title_string: "Alert", message_string: "Enter valid Email ID")
        }
        else
        {
            let contactId = self.contactDetail == nil ? nil : (self.contactDetail?.id )
            let profilePic = self.contactDetail == nil ? (self.contactImageUrl ?? "") : (self.contactDetail?.profilePic ?? "")
            let contact = ContactsAPIResponse(id: contactId, firstName: self.firstName.text!, lastName: self.lastName.text!, profilePic: profilePic, favorite: false, url: "", email: self.emailId.text!, phoneNumber: self.mobileNum.text!, createdAt: "", updatedAt: "")
            insertUpdateContact(contact: contact, isSynced: false)
        }
    }
    func insertUpdateContact(contact : ContactsAPIResponse,isSynced : Bool)
    {
        if self.contactDetail != nil
        {
            // update data
            coreDataStack.updateContact(id: contact.id ?? 0, firstName: contact.firstName ?? "", lastName: contact.lastName ?? ""  , emaild: contact.email ?? "", isFavorite: contact.favorite ?? false, phoneNum: contact.phoneNumber ?? "", profilePic: contact.profilePic ?? "", sync: isSynced){ error in
                if error == nil
                {
                    self.navigationController?.popViewController(animated: true)
                    self.updateDetailDelegate?.getUpdatedDetail(contact: contact)
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
        else
        {
            //insert data
            coreDataStack.insertContact(id: nil, firstName: contact.firstName ?? "", lastName: contact.lastName ?? "", emaild: contact.email ?? "", isFavorite: contact.favorite ?? false, phoneNum: contact.phoneNumber ?? "", profilePic: contact.profilePic ?? "", sync: isSynced){
                     self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    @objc func keyboardDidShow()
    {
        self.view.frame = CGRect(x: 0, y: -150, width: self.view.frame.width, height: self.view.frame.height)
    }
    @objc func keyboardDidHide()
    {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
}
extension CreateContactViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 5
        {
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            print(txtAfterUpdate)
            return txtAfterUpdate.count <= 15
        }
        return true
    }
}

extension CreateContactViewController : UIImagePickerControllerDelegate
{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else {
            return
        }
        contactImage.image = pickedImage
        let imageName = "Contact_\(Utils().generateRandomNumber(numDigits: 8)).png"
        Utils().saveImage(imageName: imageName, image: pickedImage){ imageName in
            if self.contactDetail != nil
            {
                self.contactDetail?.profilePic = imageName
            }
            self.contactImageUrl = imageName
        }
        dismiss(animated: true, completion: nil)
    }
}
