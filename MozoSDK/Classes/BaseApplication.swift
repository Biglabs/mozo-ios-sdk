//
//  BaseApplication.swift
//  Pods
//
//  Created by Min's Macbook on 12/07/2022.
//

import UIKit
import CoreData

open class BaseApplication: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = BundleManager.mozoBundle().url(forResource: "Mozo", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let momd = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let container = NSPersistentContainer(name: "Mozo", managedObjectModel: momd)
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    open func resetApp() {
        
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
