//
//  APICallingTests.swift
//  APICallingTests
//
//  Created by Samarth Kejriwal on 12/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import XCTest
@testable import My_Contacts

class APICallingTests: XCTestCase {

    var sut : NetworkManager!
    
    override func setUp() {
        sut = NetworkManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCallToGetContactList()
    {
        self.sut.getContacts { (data, error) in
            if error  != nil{
                XCTFail("Error : \(error ?? "")")
            }
            else
            {
                XCTAssertTrue(data != nil)
            }
        }
    }
    
    


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
