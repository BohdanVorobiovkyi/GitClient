//
//  ModuleBuilder.swift
//  GitHubClient
//
//  Created by usr01 on 26.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit

protocol Builder {
    static func createController() -> UIViewController
    
}

class ModuleBuilder: Builder {
    static func createController() -> UIViewController {
        let service = NetworkService()
        let searchVC = SearchViewController()
        let presenter = SearchPresenter(view: searchVC, service: service)
        print(presenter)
        searchVC.presenter = presenter
        return searchVC
    }
    
    
    
}
