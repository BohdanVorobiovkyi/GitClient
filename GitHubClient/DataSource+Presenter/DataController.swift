//
//  File.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation
import CoreData

protocol DataControllerDelegate: class {
    func presenterDidUpdateData(presenter: DataController)
}

final class DataController: NSObject {
    
    lazy var title: String = {
        if let lastquerry = UserDefaults.standard.object(forKey: "lastQuerry"){
            return "\(lastquerry)"
        } 
        return ""
    }()
    
    var itemsCount: Int {
        if let numberOfObjects =  fetchedResultsController.sections?.first?.numberOfObjects {
            return numberOfObjects == 0 ? 1 : numberOfObjects
        }
        //        print("result", fetchedResultsController.sections?.count)
        return 1
    }
    
    
    private var isLoading: Bool = false
    private var currentPage: Int = 1
    weak var delegate: DataControllerDelegate?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitHubClient")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<SearchItem> = {
        let fetchRequest: NSFetchRequest<SearchItem> = SearchItem.fetchRequest()
        //        fetchRequest.fetchBatchSize = 30
        let sortDescriptor = NSSortDescriptor(key: "stars", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }()
    
    override init() {
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        subscribeToContextDidSaveNotification()
    }
    
    
    
    func item(at indexPath: IndexPath) -> Item {
        let item = fetchedResultsController.object(at: indexPath)
        let id = item.id.hashValue
        return Item(
            id: id,
            fullName: item.fullName,
            owner: Owner(
                login: item.login ?? "",
                avatarURL: item.avatarURL
            ),
            htmlURL: item.htmlURL ?? "",
            itemDescription: item.itemDescription,
            forks: Int(item.forks),
            createdAt: Date(),
            updatedAt: item.updatedAt ?? Date(),
            stars: Int(item.stars),
            language: item.language
        )
    }
    
    func search(text: String, page: Int = 1) {
        if !isLoading {
        getRequest(searchText: text, page: currentPage)
        }
    }
    
    func loadNextPage(text: String) {
        if let lastquerry = UserDefaults.standard.object(forKey: "lastQuerry"), lastquerry as! String == text, !isLoading {
            getRequest(searchText:text, page: currentPage + 1)
        }
    }
    
    private func getRequest(searchText: String, page: Int) {
        isLoading = true
        NetworkService.performRequest(querry: searchText, page: page, cahcePolicy: .reloadIgnoringLocalAndRemoteCacheData) { [container = persistentContainer] (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                let context = container.newBackgroundContext()
                func deleteAll() throws {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SearchItem.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    deleteRequest.resultType = .resultTypeObjectIDs
                    let coordinator = container.persistentStoreCoordinator
                    let result = try coordinator.execute(deleteRequest, with: context) as! NSBatchDeleteResult
                    let changes: [AnyHashable: Any] = [
                        NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                    ]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context, container.viewContext])
                }
                func insert(remote: Item) throws {
                    let item = SearchItem(context: context)
                    item.avatarURL = remote.owner.avatarURL
                    item.fullName = remote.fullName
                    item.htmlURL = remote.htmlURL
                    item.itemDescription = remote.itemDescription
                    item.language = remote.language
                    item.updatedAt = remote.updatedAt
                    item.stars = Int64(remote.stars)
                }
                context.perform {
                    do {
                        let searchResults = try newJSONDecoder().decode(SearchInfoModel.self, from: data)
                        print(self.currentPage, page)
                        if self.currentPage >= page {
                            try deleteAll()
                            self.currentPage = 1
                        } else {
                            self.currentPage += 1
                        }
                        
                        if let searchItems = searchResults.items {
                            try searchItems.forEach(insert)
                        }
                        UserDefaults.standard.set(searchText, forKey: "lastQuerry") 
                        try context.save()
                    } catch {
                        self.isLoading = false
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                }
            }
        }
        
    }
    
    // MARK: NotificationCenter
    
    private let center: NotificationCenter = .default
    
    private var contextChangeObserver: NSObjectProtocol?
    
    private func subscribeToContextDidSaveNotification() {
        contextChangeObserver = center.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { [context = persistentContainer.viewContext] (notification) in
            context.perform {
                context.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    private func unsubscribeFromContextDidSaveNotification() {
        contextChangeObserver.map(center.removeObserver)
    }
    
    deinit {
        unsubscribeFromContextDidSaveNotification()
    }
    
}

extension DataController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.presenterDidUpdateData(presenter: self)
        self.isLoading = false
    }
    
}




