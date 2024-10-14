# CoreData Manager
CoreDataManager is a lightweight, generic solution for managing Core Data operations in your iOS projects. It abstracts the complexities of Core Data by providing an easy-to-use protocol-oriented API for common CRUD operations such as fetching, inserting, deleting, and saving entities.

## Content
- [Requirement](#requirement)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)

## Requirement
- iOS 13.0 or later
- XCode 11.0 or later
- Swift 5.0 or later

## Installation
There are two way to use this location manager class into your code base
- Add code snippet into your xcode.
- Manually add location manager class into your code.

### Code snippet
Download or clone the project from github repository and copy the LocationManager.codesnippet file and paste it into following directory 
```swift
/Users/[USERNAME]/Library/Developer/Xcode/UserData/CodeSnippets/
```
### Manually use code
Download or clone the project from github repo and copy LocationManager.swift file or it's code and paste it inside your codebase.

## Usage
### Quick start

#### Initialization
```swift
let coreDataStack: CoreDataStackProtocl = CoreDataStack(modelName: <#Model name#>)
let manager = CoreDataManager<<#Entity#>>(stack: coreDataStack)
```
you can use CoreDataStack with singleton pattern to just add model name inside the class e.g
```swift
static let shared = CoreDataStack(modelName: <#Model name#>)
let manager = CoreDataManager<<#Entity#>>(stack: CoreDataStack.shared)
```
#### Fetch all 
Use CoreDataManagerPotocol's fetch all method to retrive list of give entity
```swift
    let coreDataManager = CoreDataManager<<#Entity#>>(stack: CoreDataStack.shared)
    coreDataManager.fetchAll { result in
        switch result {
        case .success(let list):
            break
        case .failure(let error):
            break
        }
    }
```

#### Fetch single object 
Use CoreDataManagerPotocol's fetch all method to retrive list of give entity
```swift
let coreDataManager = CoreDataManager<<#Entity#>>(stack: CoreDataStack.shared)
    coreDataManager.fetchOne(id: <#id#>) { result in
        switch result {
        case .success(let <#model#>):
            break
        case .failure(let  error):
            break
    }
}
```
#### Create record
User inser method to create record of given entity
```swift
let person = Person(context: CoreDataStack.shared.context)
person.name = "John Appleseed"
coreDataManager.insert(person) { result in
    switch result {
    case .success(_):
        break
    case .failure(let error):
        break
    }
}
```

#### Delete record
User inser method to create record of given entity
```swift
coreDataManager.delete(<#Entity#>) { result in
    switch result {
    case .success(_):
        break
    case .failure(let error):
        break
    }
}
```

## Credits
- [Murtaza Mehmood](https://www.linkedin.com/in/murtazamehmood/)
