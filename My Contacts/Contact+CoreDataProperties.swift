//
//  Contact+CoreDataProperties.swift
//  
//
//  Created by Samarth Kejriwal on 09/06/19.
//
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var contactId: Int32
    @NSManaged public var email: String?
    @NSManaged public var favorite: Bool
    @NSManaged public var first_name: String?
    @NSManaged public var last_name: String?
    @NSManaged public var phone_number: String?
    @NSManaged public var profile_pic: String?
    @NSManaged public var syncStatus: Bool

}
