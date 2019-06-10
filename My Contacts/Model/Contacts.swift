//
//  Contacts.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 08/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation


struct ContactsSection {
    let letter : String?
    let names : [ContactsAPIResponse]
}

struct ContactsAPIResponse: Codable {
    let id: Int?
    let firstName, lastName, profilePic: String?
    let favorite: Bool?
    let url: String?
    let email : String?
    let phoneNumber : String?
    let createdAt,updatedAt : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePic = "profile_pic"
        case favorite, url
        case email
        case phoneNumber = "phone_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id : Int,firstName : String,lastName : String,profilePic : String,favorite : Bool,url : String,email : String,phoneNumber : String,createdAt : String,updatedAt : String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.profilePic = profilePic
        self.favorite = favorite
        self.url = url
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try container.decode(Int.self, forKey: .id)
        } catch  {
            id = 0
        }
        do {
            firstName = try container.decode(String.self, forKey: .firstName)
        } catch  {
            firstName = ""
        }
        do {
            lastName = try container.decode(String.self, forKey: .lastName)
        } catch  {
            lastName = ""
        }
        do {
            profilePic = try container.decode(String.self, forKey: .profilePic)
        } catch  {
            profilePic = ""
        }
        do {
            favorite = try container.decode(Bool.self, forKey: .favorite)
        } catch  {
            favorite = false
        }
        do {
            url = try container.decode(String.self, forKey: .url)
        } catch  {
            url = ""
        }
        do {
            email = try container.decode(String.self, forKey: .email)
        } catch  {
            email = ""
        }
        do {
            phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        } catch  {
            phoneNumber = ""
        }
        do {
            createdAt = try container.decode(String.self, forKey: .createdAt)
        } catch  {
            createdAt = ""
        }
        do {
            updatedAt = try container.decode(String.self, forKey: .updatedAt)
        } catch  {
            updatedAt = ""
        }
    }
}


typealias Contacts = [ContactsAPIResponse]



