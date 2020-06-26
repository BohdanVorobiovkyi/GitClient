//
//  DetailsPresenter.swift
//  GitHubClient
//
//  Created by usr01 on 26.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

protocol DetailsViewProtocol: class {
    func configure(with title: String?, description: String?, date: String, language: String?, htmlURL: String)
    func setImage(stringUrl : String?)
}

protocol DetailsViewPresenterProtocol: class {

    init(view: DetailsViewProtocol, item: Item)
    func showView()

}

final class DetailsPresenter: DetailsViewPresenterProtocol {
    
    private weak var view: DetailsViewProtocol?
    private var item: Item
    
    init(view: DetailsViewProtocol, item : Item) {
        self.view = view
        self.item = item
        showView()
    }

    func showView()  {
        if let avatarUrlString = item.owner.avatarURL {
            view?.setImage(stringUrl: avatarUrlString)
        }
        let titleText = item.fullName
        let descriptionText = item.itemDescription
        let languageText = item.language != nil ? "Language: \(item.language!) " : ""
        let dateText = "Updated at: " + DateFormatter().getStringDate(date: item.updatedAt)
//              dateLabel.text = "Updated at: " + DateFormatter().getStringDate(date: with.updatedAt)
        view?.configure(with: titleText, description: descriptionText, date: dateText, language: languageText, htmlURL: item.htmlURL)
    }



}
