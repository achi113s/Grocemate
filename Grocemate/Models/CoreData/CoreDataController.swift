//
//  DataController.swift
//  GroceMate
//
//  Created by Giorgio Latour on 11/4/23.
//

import CoreData
import Foundation
import SwiftUI

final class CoreDataController {

    /// Create a singleton instance of this class.
    static let shared = CoreDataController()

    private let persistentContainer: NSPersistentCloudKitContainer

    /// The main view context.
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// A background context to use in our views for editing CoreData objects.
    /// This background context executes on a private queue.
    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    private init() {
        /// Set up the model, context, and store all at once with an NSPersistentContainer.
        persistentContainer = NSPersistentCloudKitContainer(name: "GrocemateDataModel")

        /// Are we in an Xcode preview or XCTest? If yes, make the persistent container in memory.
        if EnvironmentValues.isPreview || Thread.current.isRunningXCTest {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(fileURLWithPath: "/dev/null")
        }

        /// Load the persistent stores.
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                print("There was an error loading the persistent stores: \(error)")
                return
            } else {
                /// Automatically merge any changes saved to the parent store.
                /// Useful since we will have multiple viewContexts.
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

                self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                print("Successfully loaded CoreData.")
            }
        }

//        // Only initialize the schema when building the app with the
//        // Debug build configuration.
//#if DEBUG
//        do {
//            // Use the container to initialize the development schema.
//            print("Initializing CloudKit schema.")
//            try persistentContainer.initializeCloudKitSchema(options: [])
//        } catch {
//            // Handle any errors.
//            print("An error occurred when initializing the CloudKit schema: \(error)")
//        }
//#endif
    }

    func exists<T: NSManagedObject>(_ object: T,
                                    in context: NSManagedObjectContext) -> T? {
        try? context.existingObject(with: object.objectID) as? T
    }

    func delete<T: NSManagedObject>(_ object: T,
                                    in context: NSManagedObjectContext) throws {
        if let existingObject = exists(object, in: context) {
            /// Bug: Does not delete with an animation?
            context.delete(existingObject)

            /// Task to delete from context on background thread.
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }

    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

extension EnvironmentValues {
    /// Are we in an Xcode preview?
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

extension Thread {
    /// Are we in testing mode?
    var isRunningXCTest: Bool {
        for key in self.threadDictionary.allKeys {
            guard let keyAsString = key as? String else {
                continue
            }

            if keyAsString.split(separator: ".").contains("xctest") {
                return true
            }
        }

        return false
    }
}
