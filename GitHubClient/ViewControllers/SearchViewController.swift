//
//  SearchViewController.swift
//  GitHubClient
//
//  Created by usr01 on 22.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit
import SnapKit
import ProgressHUD

protocol NextPageDelegate: class {
    func loadNextPage()
}

class SearchViewController: UIViewController {
    

    private let reuseIdentifier = "SearchCell"
    var presenter: SearchViewPresenterProtocol!

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        sb.translatesAutoresizingMaskIntoConstraints = true
        sb.showsCancelButton = true
        sb.isTranslucent = true
        return sb
    }()
   
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInsetReference = .fromSafeArea
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100 ), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.lightText
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .systemGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(searchBar)
        setupSearchBar()
        setupTitle()
        setupCollectionView()
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = false
    }
    
    private func setupSearchBar() {
        self.searchBar.text = presenter.lastQuerryText
        searchBar.delegate = self
        // Cancel Button Color
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.darkGray], for: .normal)
    }
    
    private func setupTitle() {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 28))
        iv.contentMode = .scaleAspectFit
        iv.image = MocConstants.topLogo
        self.navigationItem.titleView = iv
    }
    
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = .lightGray
        collectionView.register(ResultCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40)
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        let cellHeight = ResultCell.cellHeight
        return CGSize(width: availableWidth - 80, height: cellHeight)
    }
}

extension SearchViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  presenter.itemsCount
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if presenter.itemsCount == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResultCell
            cell.isUserInteractionEnabled = false
            let searchText = searchBar.text ?? ""
            let noMatchesModel = presenter.noResultsItem(for: searchText)
            cell.configureCell(model: noMatchesModel)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResultCell
        cell.isUserInteractionEnabled = true
        cell.configureCell(model: presenter.item(at: indexPath))
        return cell
    }

}
extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let details = ModuleBuilder.createDetailsController(for: presenter.item(at: indexPath))
//        details
        self.navigationController?.present(details, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= collectionView.contentSize.height * 0.8)
        {
            let text = searchBar.text ?? ""
            ProgressHUD.show()
            presenter.loadNextPage(text: text)
        }
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text , text.count > 0 {
            ProgressHUD.show()
            presenter.search(text: text, page: 1)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ProgressHUD.show()
        self.searchBar.text?.removeAll()
        self.searchBar.showsCancelButton = true
        self.presenter.search(text: "", page: 1)
        self.collectionView.endEditing(true)
        ProgressHUD.dismiss()
    }
}

extension SearchViewController: SearchViewProtocol {
 
    func updateCollection() {
        collectionView.reloadData()
        ProgressHUD.showSuccess()
    }
}
