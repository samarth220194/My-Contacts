//
//  CoreDataManger.swift
//  My Contacts
//
//  Created by Samarth Kejriwal on 09/06/19.
//  Copyright © 2019 Samarth Kejriwal. All rights reserved.
//

import Foundation
import CoreData
import UIKit


final class CoreDataStack {
   
    public let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    public lazy var privateManagedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.managedObjectContext
        
        return managedObjectContext
    }()
    
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        return managedObjectModel
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return coordinator
    }()
    
    @objc func saveChanges() {
        privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            if let parent = self.managedObjectContext.parent, parent == self.managedObjectContext && parent.hasChanges {
                parent.perform() {
                    do {
                        try parent.save()
                        print("parent context saved")
                    }
                    catch(let error) {
                        print(error)
                        return
                    }
                }
            }
            else
            {
                 print("parent context not saved as there are no changes")
            }
        }
    }
    
    
    // MARK: - Core Data Saving support
    private func saveContext (managedObjectContext: NSManagedObjectContext,
                             completion: @escaping (_ error: NSError?) -> () ) {
        
        if !managedObjectContext.hasChanges {
            completion(nil)
            return
        }
        
        do {
            try managedObjectContext.save()
        }
        catch(let error) {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            completion(nserror)
            return
        }
        
        // When using SQLite store and the managed object context's parent is the main MOC,
        // save the parent object context to persist to the persistence store coordinator
        if let parent = managedObjectContext.parent, parent == self.managedObjectContext {
            
            parent.perform() {
                do {
                    try parent.save()
                    print("parent context saved")
                }
                catch(let error) {
                    completion(error as NSError)
                    return
                }
                completion(nil)
            }
        }
        else
        {
            print("parent context not saved")
        }
    }
    
    func insertAllContacts(contacts : [ContactsAPIResponse],_ completion : @escaping() -> ())
    {
        self.privateManagedObjectContext.perform {
            let entity = NSEntityDescription.entity(forEntityName: "Contact",
                                                    in: self.privateManagedObjectContext)!
            for contact in contacts
            {
                let contactObject = NSManagedObject(entity: entity,
                                              insertInto: self.privateManagedObjectContext)
                
                contactObject.setValue(contact.firstName ?? "", forKey: "first_name")
                contactObject.setValue(contact.lastName ?? "", forKey: "last_name")
                contactObject.setValue(contact.email ?? "", forKey: "email")
                contactObject.setValue(contact.favorite ?? false, forKey: "favorite")
                contactObject.setValue(contact.phoneNumber ?? "", forKey: "phone_number")
                contactObject.setValue(contact.profilePic ?? "", forKey: "profile_pic")
                contactObject.setValue(true, forKey: "syncStatus")
                contactObject.setValue(contact.id ?? 0, forKey: "contactId")
            }
            self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                print("Saved successfully")
                completion()
            }
        }
    }
    
    func insertContact(id : Int?,firstName : String,lastName : String,emaild : String,isFavorite : Bool,phoneNum : String,profilePic : String,sync : Bool,_ completion : @escaping() -> ()) {
        
        self.privateManagedObjectContext.perform {
            let entity = NSEntityDescription.entity(forEntityName: "Contact",
                                                    in: self.privateManagedObjectContext)!
            var objectId = Int()
            let contact = NSManagedObject(entity: entity,
                                          insertInto: self.privateManagedObjectContext)
            objectId = id == nil ? (contact.objectID.hashValue * (-1)) : id!
            
            contact.setValue(firstName, forKey: "first_name")
            contact.setValue(lastName, forKey: "last_name")
            contact.setValue(emaild, forKey: "email")
            contact.setValue(isFavorite, forKey: "favorite")
            contact.setValue(phoneNum, forKey: "phone_number")
            contact.setValue(profilePic, forKey: "profile_pic")
            contact.setValue(sync, forKey: "syncStatus")
            contact.setValue(objectId, forKey: "contactId")
            self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                print("Saved successfully")
                completion()
            }
        }
    }
    
    func fetchAllContacts(_ completion : @escaping([Contact]?) -> ()) {
        
        self.privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
                let people = try self.managedObjectContext.fetch(fetchRequest)
                completion(people as? [Contact])
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
                completion([])
            }
        }
    }
    
    
    func deleteAllContacts(_ completion : @escaping()-> ())
    {
        self.privateManagedObjectContext.perform {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            do {
                let item = try self.privateManagedObjectContext.fetch(fetchRequest)
                for i in item {
                    self.privateManagedObjectContext.delete(i)
                }
                self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                    print("Deleted successfully")
                     completion()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
                completion()
            }
        }
    }
    
    func fetchUnsysncContacts(_ completion : @escaping([Contact]?) -> ())
    {
        self.privateManagedObjectContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            fetchRequest.predicate = NSPredicate(format: "syncStatus == %@" ,NSNumber(booleanLiteral: false))
            do {
                let contactsObject = try self.privateManagedObjectContext.fetch(fetchRequest)
                completion(contactsObject as? [Contact])
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                 completion([])
            }
        }
    }
    
    func fetchContactDetail(id : Int, _ completion : @escaping([Contact]?) -> ())
    {
        self.privateManagedObjectContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: id))
            do {
                let contactsObject = try self.privateManagedObjectContext.fetch(fetchRequest)
                completion(contactsObject as? [Contact])
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                completion([])
            }
        }
    }
    
    func updateContact(id:Int, firstName : String,lastName : String,emaild : String,isFavorite : Bool,phoneNum : String,profilePic : String,sync : Bool,_ completion : @escaping(Error?)->()) {
        
        self.privateManagedObjectContext.perform {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: id))
            do {
                let item = try self.privateManagedObjectContext.fetch(fetchRequest)
                for i in item {
                    i.setValue(firstName, forKey: "first_name")
                    i.setValue(lastName, forKey: "last_name")
                    i.setValue(emaild, forKey: "email")
                    i.setValue(isFavorite, forKey: "favorite")
                    i.setValue(phoneNum, forKey: "phone_number")
                    i.setValue(profilePic, forKey: "profile_pic")
                    i.setValue(sync, forKey: "syncStatus")
                    i.setValue(id, forKey: "contactId")
                }
                self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                    print("Updated successfully")
                    completion(nil)
                }
                
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
                completion(error)
            }
        }
    }
    func syncContact(oldId : Int,newId : Int)
    {
        self.privateManagedObjectContext.perform {
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
            fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: oldId))
            do {
                let item = try self.privateManagedObjectContext.fetch(fetchRequest)
                for i in item {
                    i.setValue(true, forKey: "syncStatus")
                    i.setValue(newId, forKey: "contactId")
                }
                self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                    print("synced successfully")
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
    
    func delete(id: Int){
        
        self.privateManagedObjectContext.perform {
            do {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
                fetchRequest.predicate = NSPredicate(format: "contactId == %@" ,NSNumber(integerLiteral: id))
                
                let item = try self.managedObjectContext.fetch(fetchRequest)
                for i in item {
                    self.managedObjectContext.delete(i)
                }
                self.saveContext(managedObjectContext: self.privateManagedObjectContext){ error in
                    print("Deleted Contact successfully")
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
    
}
