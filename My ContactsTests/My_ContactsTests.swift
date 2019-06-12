//
//  My_ContactsTests.swift
//  My ContactsTests
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import XCTest
import CoreData
@testable import My_Contacts

class My_ContactsTests: XCTestCase {

    var sut : CoreDataStack!
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = CoreDataStack(modelName: "My_Contacts")
    }
    
    func testPersistantStoreCreation() {
        XCTAssertTrue(self.sut.persistentStoreCoordinator.persistentStores.count > 0)
    }
    func testBackgroundContextConcurrencyType() {
       
        let setupExpectation = expectation(description: "background context")
        XCTAssertEqual(self.sut.privateManagedObjectContext.concurrencyType, .privateQueueConcurrencyType)
        setupExpectation.fulfill()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testMainContextConcurrencyType() {
        let setupExpectation = expectation(description: "main context")
        XCTAssertEqual(self.sut.managedObjectContext.concurrencyType, .mainQueueConcurrencyType)
        setupExpectation.fulfill()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCoreDataInsertion() {
        sleep(5)
        let contact1 = ContactsAPIResponse(id: 1234, firstName: "Samarth", lastName: "Kejriwal", profilePic: "", favorite: false, url: "", email: "sam@gmail.com", phoneNumber: "9044528822", createdAt: "", updatedAt: "")
        let contact2 = ContactsAPIResponse(id: 1235, firstName: "Samarth1", lastName: "Kejriwal1", profilePic: "", favorite: false, url: "", email: "sam@gmail1.com", phoneNumber: "9044528821", createdAt: "", updatedAt: "")
        
        self.sut.delete(id: 1234)
        self.sut.delete(id: 1235)
        self.sut.insertAllContacts(contacts: [contact1,contact2]){}
        
        self.sut.fetchContactDetail(id: 1234){ contacts in
            guard let _ = contacts?.first else {
                XCTFail("contact is missing")
                return
            }
            XCTAssertEqual(contacts?.count, 1)
        }
    }
    
    func testCoreDataUpdate()
    {
        /*fetch all items*/
        self.sut.fetchAllContacts(){
            contacts in
            XCTAssertTrue((contacts?.count ?? 0) > 0)
            let person = contacts?[0]
            let name = "Sammy"
            
            self.sut.updateContact(id: Int(person?.contactId ?? 0), firstName: name, lastName: person?.last_name ?? "", emaild: person?.email ?? "", isFavorite: person?.favorite ?? false, phoneNum: person?.phone_number ?? "", profilePic: person?.profile_pic ?? "" , sync: false){_ in
                self.sut.fetchContactDetail(id: Int(person?.contactId ?? 0)){ contacts in
                    XCTAssertEqual(name, contacts?[0].first_name ?? "")
                }
            }
        }
    }
    
    func testCoreDataDeletion() {
        sleep(5)
        
        self.sut.fetchAllContacts(){contacts in
            XCTAssertTrue((contacts?.count ?? 0) > 0)
            let contact = contacts?[0]
            let numItems = contacts?.count
            
            self.sut.delete(id: (contact?.value(forKey: "contactId") as? Int) ?? 0)
            self.sut.fetchAllContacts() {
                afterDeletioncontacts in
                XCTAssertEqual(afterDeletioncontacts?.count, numItems! - 1)
            }
            
        }
    }

    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
