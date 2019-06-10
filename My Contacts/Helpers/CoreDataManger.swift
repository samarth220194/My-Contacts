//
//  CoreDataManger.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 09/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let sharedManager = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "My_Contacts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertContact(id:Int?, firstName : String,lastName : String,emaild : String,isFavorite : Bool,phoneNum : String,profilePic : String,sync : Bool) {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
       
        let entity = NSEntityDescription.entity(forEntityName: "Contact",
                                                in: managedContext)!
        let contact = NSManagedObject(entity: entity,
                                      insertInto: managedContext)
        contact.setValue(firstName, forKey: "first_name")
        contact.setValue(lastName, forKey: "last_name")
        contact.setValue(emaild, forKey: "email")
        contact.setValue(isFavorite, forKey: "favorite")
        contact.setValue(phoneNum, forKey: "phone_number")
        contact.setValue(profilePic, forKey: "profile_pic")
        contact.setValue(sync, forKey: "syncStatus")
        contact.setValue(id, forKey: "contactId")
        do {
            try managedContext.save()
            print("saved")
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func deleteAllContacts()
    {
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        CoreDataManager.sharedManager.persistentContainer.performBackgroundTask() { (context) in
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            do {
                let item = try context.fetch(fetchRequest)
                for i in item {
                    context.delete(i)
                    try context.save()
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchUnsysncContacts() ->  [Contact]?
    {
        var contacts : [Contact]? = []
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "syncStatus == %@" ,NSNumber(booleanLiteral: false))
        
        do {
            let contactsObject = try context.fetch(fetchRequest)
            contacts = contactsObject as? [Contact]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return contacts
    }
    
    func fetchContactDetail(id : Int) -> [Contact]?
    {
        var contacts : [Contact]? = []
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: id))
        
        do {
            let contactsObject = try context.fetch(fetchRequest)
            contacts = contactsObject as? [Contact]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return contacts
    }
    
    func updateContact(id:Int, firstName : String,lastName : String,emaild : String,isFavorite : Bool,phoneNum : String,profilePic : String,sync : Bool) {
        
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: id))
        
        do {
            let item = try context.fetch(fetchRequest)
            for i in item {
                i.setValue(firstName, forKey: "first_name")
                i.setValue(lastName, forKey: "last_name")
                i.setValue(emaild, forKey: "email")
                i.setValue(isFavorite, forKey: "favorite")
                i.setValue(phoneNum, forKey: "phone_number")
                i.setValue(profilePic, forKey: "profile_pic")
                i.setValue(sync, forKey: "syncStatus")
                i.setValue(id, forKey: "contactId")
                try context.save()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func syncContact(contact : Contact,id : Int)
    {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        do {
            contact.setValue(true, forKey: "syncStatus")
            contact.setValue(id, forKey: "contactId")
            try context.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func delete(id: Int){
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,id)
            do {
                let item = try managedContext.fetch(fetchRequest)
                for i in item {
                    managedContext.delete(i)
                    try managedContext.save()
                }
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
    }
    func fetchAllContacts() -> [Contact]?{
        var contacts : [Contact]? = []
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        do {
            let people = try managedContext.fetch(fetchRequest)
            contacts = people as? [Contact]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return contacts
    }
}
