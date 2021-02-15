//
//  Manager.swift
//  dictionary
//
//  Created by Handika Limanto on 15/02/21.
//

import Foundation
import CoreData

class Manager{
    
    // Arrays
    static var definitions = [Definition]()
    static var words = [NSManagedObject]()
    
    // API management
    static let baseURL = "https://owlbot.info/api/v4/dictionary/"
    static let token = "Token b3571aa0c91b5765725ed4ca284f09ffa99e30f1"
    static let headers = [
        "content-type": "application/json",
        "authorization": token
    ]
    
    // CoreData
    static var context: NSManagedObjectContext!
    static func initCoreData(_ appDelegate: AppDelegate){
        context = appDelegate.persistentContainer.viewContext
    }
    
    // CoreData
    static func getWord(_ index: Int) -> Word{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        var result = [NSManagedObject]()
        do {
            result = try context.fetch(request) as! [NSManagedObject]
        } catch {
            // error here
            print("Failed to load data")
        }
        return Word(result[index].value(forKey: "word") as! String, result[index].value(forKey: "definitions") as! String)
    }
    
}
