//
//  CoreDataManager.swift
//  CoreDataManager
//
//  Created by Murtaza Mehmood on 13/10/2024.
//

import Foundation
import CoreData

//MARK: - ESSENTIAL PREDICATE
/**
// 1. Equality (=)
let predicate = NSPredicate(format: "name == %@", "John")
// SQL Equivalent:
SELECT * FROM Entity WHERE name = 'John';

// 2. Inequality (!=)
let predicate = NSPredicate(format: "age != %d", 25)
// SQL Equivalent:
SELECT * FROM Entity WHERE age != 25;

// 3. Greater Than (>)
let predicate = NSPredicate(format: "age > %d", 18)
// SQL Equivalent:
SELECT * FROM Entity WHERE age > 18;

// 4. Less Than (<)
let predicate = NSPredicate(format: "salary < %f", 50000.0)
// SQL Equivalent:
SELECT * FROM Entity WHERE salary < 50000.0;

// 5. BETWEEN
let predicate = NSPredicate(format: "age BETWEEN {18, 30}")
// SQL Equivalent:
SELECT * FROM Entity WHERE age BETWEEN 18 AND 30;

// 6. LIKE (Wildcard Matching)
let predicate = NSPredicate(format: "name LIKE[c] %@", "J*")
// SQL Equivalent:
SELECT * FROM Entity WHERE name LIKE 'J%';

// 7. CONTAINS
let predicate = NSPredicate(format: "name CONTAINS[c] %@", "John")
// SQL Equivalent:
SELECT * FROM Entity WHERE name LIKE '%John%';

// 8. IN
let predicate = NSPredicate(format: "name IN %@", ["John", "Jane", "Alice"])
// SQL Equivalent:
SELECT * FROM Entity WHERE name IN ('John', 'Jane', 'Alice');

// 9. AND Condition
let predicate = NSPredicate(format: "name == %@ AND age > %d", "John", 20)
// SQL Equivalent:
SELECT * FROM Entity WHERE name = 'John' AND age > 20;

// 10. OR Condition
let predicate = NSPredicate(format: "name == %@ OR age < %d", "John", 18)
// SQL Equivalent:
SELECT * FROM Entity WHERE name = 'John' OR age < 18;

// 11. NOT Condition
let predicate = NSPredicate(format: "NOT (name == %@)", "John")
// SQL Equivalent:
SELECT * FROM Entity WHERE NOT (name = 'John');

// 12. NULL Check
let predicate = NSPredicate(format: "address == nil")
// SQL Equivalent:
SELECT * FROM Entity WHERE address IS NULL;

// 13. SUBQUERY
let predicate = NSPredicate(format: "SUBQUERY(employees, $x, $x.salary > 50000).@count > 0")
// SQL Equivalent:
SELECT * FROM Entity WHERE (SELECT COUNT(*) FROM employees WHERE salary > 50000) > 0;

// 14. Aggregate Functions (COUNT)
let predicate = NSPredicate(format: "employees.@count >= %d", 5)
// SQL Equivalent:
SELECT * FROM Entity WHERE (SELECT COUNT(*) FROM employees) >= 5;

// 15. SELF Comparison
let predicate = NSPredicate(format: "SELF == %@", someObject)
// SQL Equivalent:
SELECT * FROM Entity WHERE Entity = someObject;
*/

// MARK: - CoreDataStackProtocl

/// Protocol that defines the core functionalities of a Core Data stack.
/// It provides access to the `NSPersistentContainer` and `NSManagedObjectContext`
/// and also contains a method to save changes to the context.
protocol CoreDataStackProtocol {
    
    /// The persistent container that holds the Core Data stack, including the
    /// managed object model, persistent store coordinator, and managed object context.
    var persistantContainer: NSPersistentContainer { get }
    
    /// The main `NSManagedObjectContext` used for interacting with Core Data entities.
    var context: NSManagedObjectContext { get }
    
    /// Saves changes in the `NSManagedObjectContext` if there are any unsaved changes.
    func saveContext()
}

// MARK: - CoreDataStack

/// A concrete implementation of `CoreDataStackProtocl` that manages the Core Data stack
/// and provides an interface to save and retrieve data from the Core Data database.
final class CoreDataStack: CoreDataStackProtocol {
    
    // The persistent container used for managing the Core Data stack.
    let persistantContainer: NSPersistentContainer
    
    // Singleton instance of CoreDataStack for shared usage.
    static let shared = CoreDataStack(modelName: <#Model name#>)
    
    /// Initializes the Core Data stack with a given model name.
    ///
    /// - Parameter modelName: The name of the Core Data model file (without the extension).
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
        persistantContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
    }
    
    /// The main `NSManagedObjectContext` for interacting with Core Data.
    var context: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    /// Saves the current context if there are any unsaved changes. This method should
    /// be called after making any changes to the managed object context to persist data.
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("Failed to save context: \(error)")
            }
        }
    }
}

// MARK: - CoreDataManagerProtocol

/// A protocol defining the core CRUD operations for managing Core Data entities.
/// This protocol is designed to handle any type of `NSManagedObject` by using generics.
protocol CoreDataManagerProtocol {
    
    /// The type of entity managed by the Core Data manager. Must conform to `NSManagedObject`.
    associatedtype Entity: NSManagedObject
    
    /// Fetches all entities of the specified type from the Core Data store.
    ///
    /// - Parameter completion: A completion handler that returns a result containing either
    ///   a list of entities or an error if the fetch operation fails.
    func fetchAll(completion: (Result<[Entity], Error>) -> Void)
    
    /// Fetches a single entity based on the provided identifier.
    ///
    /// - Parameter id: The unique identifier of the entity.
    /// - Parameter completion: A completion handler that returns a result containing either
    ///   the fetched entity or an error if the fetch operation fails.
    func fetchOne(id: Int, completion: (Result<Entity, Error>) -> Void)
    
    /// Inserts a new entity into the Core Data store.
    ///
    /// - Parameter entity: The entity to be inserted.
    /// - Parameter completion: A completion handler that returns a result containing either
    ///   the inserted entity or an error if the insertion fails.
    func insert(_ entity: Entity, completion: (Result<Entity, Error>) -> Void)
    
    /// Deletes an entity from the Core Data store.
    ///
    /// - Parameter entity: The entity to be deleted.
    /// - Parameter completion: A completion handler that returns a result containing either
    ///   the deleted entity or an error if the deletion fails.
    func delete(_ entity: Entity, completion: (Result<Entity, Error>) -> Void)
    
    /// Saves any unsaved changes in the Core Data context.
    func save()
}

// MARK: - CoreDataManager

/// A generic Core Data manager that implements the `CoreDataManagerProtocol`. This class
/// provides CRUD operations for any type of `NSManagedObject`.
///
/// - Note: This class is designed to work with any entity in the Core Data store.
final class CoreDataManager<Entity: NSManagedObject>: CoreDataManagerProtocol {
    
    // The Core Data stack responsible for managing the persistent container and context.
    private let stack: CoreDataStackProtocol
    
    /// Initializes the Core Data manager with a given Core Data stack.
    ///
    /// - Parameter stack: The Core Data stack that provides access to the context and persistent container.
    init(stack: CoreDataStackProtocol) {
        self.stack = stack
    }
    
    /// Fetches all entities from the Core Data store.
    ///
    /// - Parameter completion: A completion handler that returns either a list of entities or an error.
    func fetchAll(completion: (Result<[Entity], Error>) -> Void) {
        let context = stack.context
        let request = Entity.fetchRequest()
        do {
            let list = try context.fetch(request) as! [Entity]
            completion(.success(list))
        } catch let error {
            print(error.localizedDescription)
            completion(.failure(error))
        }
    }
    
    /// Fetches a single entity by its identifier.
    ///
    /// - Parameter id: The identifier of the entity to be fetched.
    /// - Parameter completion: A completion handler that returns either the fetched entity or an error.
    func fetchOne(id: Int, completion: (Result<Entity, Error>) -> Void) {
        let request = Entity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let result = try stack.context.fetch(request)
            completion(.success(result.first as! Entity))
        } catch {
            print("Failed to fetch one: \(error)")
            completion(.failure(error))
        }
    }
    
    /// Inserts a new entity into the Core Data store.
    ///
    /// - Parameter entity: The entity to be inserted.
    /// - Parameter completion: A completion handler that returns either the inserted entity or an error.
    func insert(_ entity: Entity, completion: (Result<Entity, Error>) -> Void) {
        do {
            stack.persistantContainer.viewContext.insert(entity)
            try stack.context.save()
            completion(.success(entity))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    /// Deletes an entity from the Core Data store.
    ///
    /// - Parameter entity: The entity to be deleted.
    /// - Parameter completion: A completion handler that returns either the deleted entity or an error.
    func delete(_ entity: Entity, completion: (Result<Entity, Error>) -> Void) {
        do {
            stack.context.delete(entity)
            try stack.context.save()
            completion(.success(entity))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    /// Saves any unsaved changes in the Core Data context.
    func save() {
        stack.saveContext()
    }
}
