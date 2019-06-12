//
//  CreateContactViewControllerTests.swift
//  CreateContactViewControllerTests
//
//  Created by Samarth Kejriwal on 12/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import XCTest
@testable import My_Contacts

class CreateContactViewControllerTests: XCTestCase {

    var sut : CreateContactViewController!
   
    override func setUp() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "createContact") as! CreateContactViewController
        sut = vc
        _ = sut.view
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testContactCreation()
    {
        self.sut.firstName.text = "Samarth"
        self.sut.lastName.text = "Kejriwal"
        self.sut.mobileNum.text = "9044528822"
        self.sut.emailId.text = "werrew@gmail.com"
        
        let contact = ContactsAPIResponse(id: nil, firstName: self.sut.firstName.text!, lastName: self.sut.lastName.text!, profilePic: "", favorite: false, url: "", email: self.sut.emailId.text!, phoneNumber: self.sut.mobileNum.text!, createdAt: "", updatedAt: "")
        
        self.sut.insertUpdateContact(contact: contact, isSynced: false)
        
        
    }
    func testvalidateDetails()
    {
        self.sut.mobileNum.text = "9044538822"
        self.sut.emailId.text = "wewe@gmail.com"
        
        
        XCTAssertTrue(ValidationUtils.isValidMobile(mobile: self.sut.mobileNum.text!))
        XCTAssertTrue(ValidationUtils.isValidEmail(email: self.sut.emailId.text!))
        
    }
    
    

    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
