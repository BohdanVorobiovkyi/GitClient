//
//  SearchPresenter.swift
//  GitHubClient
//
//  Created by usr01 on 25.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation
import CoreData


protocol SearchViewProtocol: class {
    func updateCollection()
}

protocol SearchViewPresenterProtocol: class {
    var itemsCount: Int { get }
    var lastQuerryText: String { get }
    
    init(view: SearchViewProtocol)
    func item(at indexPath: IndexPath) -> Item
    func noResultsItem(for querry: String) -> Item
    func loadNextPage(text: String)
    func search(text: String, page: Int )
    
}

extension SearchPresenter: SearchViewPresenterProtocol {
    func noResultsItem(for querry: String) -> Item {
       return Item(id: 0, fullName: "No matches found with your reques \"\(querry)\"", owner: Owner(login: "", avatarURL: "https://images.app.goo.gl/PBRqp2bCv7xW43KC8"), htmlURL: "", itemDescription: "", forks: 0, createdAt: Date(), updatedAt: Date(), stars: 0, language: nil)
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
    
    func search(text: String, page: Int) {
        if !isLoading {
            getRequest(searchText: text, page: currentPage)
        }
    }
    
    func loadNextPage(text: String) {
        if let lastquerry = UserDefaults.standard.object(forKey: "lastQuerry"), lastquerry as! String == text, !isLoading {
            getRequest(searchText:text, page: currentPage + 1)
        }
    }
}


final class SearchPresenter: NSObject {
    
    private weak var view: SearchViewProtocol!
    private var isLoading: Bool = false
    private var currentPage: Int = 1

    lazy var lastQuerryText: String = {
        if let lastquerry = UserDefaults.standard.object(forKey: "lastQuerry"){
            return "\(lastquerry)"
        }
        return ""
    }()
    
    var itemsCount: Int {
        if let numberOfObjects =  fetchedResultsController.sections?.first?.numberOfObjects {
            return numberOfObjects == 0 ? 1 : numberOfObjects
        }
        return 1
    }
    
    required init(view: SearchViewProtocol) {
        self.view = view
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
    
    //MARK: CoreData container an fetchedResultsController
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
    
   //MARK: Network request with re-saving results to CD / Next batch load
    private func getRequest(searchText: String, page: Int) {
        isLoading = true
        NetworkService.performRequest(querry: searchText, page: page, cahcePolicy: .reloadIgnoringLocalAndRemoteCacheData) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let data):
                guard let strongSelf = self else { return }
                let context = strongSelf.persistentContainer.newBackgroundContext()
                func deleteAll() throws {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SearchItem.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    deleteRequest.resultType = .resultTypeObjectIDs
                    let coordinator = strongSelf.persistentContainer.persistentStoreCoordinator
                    let result = try coordinator.execute(deleteRequest, with: context) as! NSBatchDeleteResult
                    let changes: [AnyHashable: Any] = [
                        NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
                    ]
                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: changes,
                        into: [context, strongSelf.persistentContainer.viewContext]
                    )
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
                do {
                    let searchResults = try newJSONDecoder().decode(SearchInfoModel.self, from: data)
                    if strongSelf.currentPage >= page {
                        try deleteAll()
                        strongSelf.currentPage = 1
                    } else {
                        strongSelf.currentPage += 1
                    }
                    UserDefaults.standard.set(searchText, forKey: "lastQuerry")
                    context.perform {
                        do {
                            if let searchItems = searchResults.items {
                                try searchItems.forEach(insert)
                            }
                            try context.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Core Data error \(nserror), \(nserror.userInfo)")
                        }
                    }
                } catch {
                    strongSelf.isLoading = false
                    let nserror = error as NSError
                    fatalError("Decoding error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    // MARK: NotificationCenter for contextChange
    
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



extension SearchPresenter : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.view.updateCollection()
        self.isLoading = false
    }
    
}
