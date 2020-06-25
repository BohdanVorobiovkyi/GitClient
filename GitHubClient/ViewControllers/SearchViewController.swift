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
    
    let dataController = DataController()
    private let reuseIdentifier = "SearchCell"
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    //    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var collectionView : UICollectionView = {
        //        let collection = UICollectionView()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInsetReference = .fromSafeArea
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: searchBar.frame.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.lightText
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .systemGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    //    
    //    let collectionView = UICollectionView()
    
    private var searchDelayer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.delegate = self
        setupSearchBar()
        setupTitle()
        setupCollectionView()
        
    }
    
    private func setupTitle() {
        self.searchBar.text = dataController.title
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 28))
        iv.contentMode = .scaleAspectFit
        iv.image = MocConstants.topLogo
        self.navigationItem.titleView = iv
        
    }
    
    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .lightGray
        collectionView.register(ResultCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
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
        return dataController.itemsCount
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataController.itemsCount == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResultCell
            cell.isUserInteractionEnabled = false
            let searchText = searchBar.text ?? ""
            let noMatchesModel = Item(id: 0, fullName: "No matches found with your reques \"\(searchText)\"", owner: Owner(login: "", avatarURL: "https://images.app.goo.gl/PBRqp2bCv7xW43KC8"), htmlURL: "", itemDescription: "", forks: 0, createdAt: Date(), updatedAt: Date(), stars: 0, language: nil)
            cell.configureCell(model: noMatchesModel)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ResultCell
        cell.isUserInteractionEnabled = true
        cell.configureCell(model: dataController.item(at: indexPath))
        return cell
    }
    
}
extension SearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailsVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailsVC") as? DetailsViewController {
            detailsVC.configureVC(with: dataController.item(at: indexPath))
            self.navigationController?.present(detailsVC, animated: true, completion: nil)
            //            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= collectionView.contentSize.height * 0.8)
        {
            let text = searchBar.text ?? ""
            ProgressHUD.show()
            dataController.loadNextPage(text: text)
        }
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    private func setupSearchBar() {
        searchBar.delegate = self
        // Cancel Button Color
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray], for: .disabled)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.darkGray], for: .normal)
    }
    
    @objc private func search(_ gesture: UITapGestureRecognizer) {
//        if let text = searchBar.text , text.count > 0 {
//            ProgressHUD.show()
//            dataController.search(text: text)
//        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text , text.count > 0 {
            ProgressHUD.show()
            dataController.search(text: text)
        }
    }
    
//    private func adjustSearch() {
//        if let text = searchBar.text , text.count > 0 {
//            ProgressHUD.show()
//            dataController.search(text: text)
//        }
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDelayer.invalidate()
        searchDelayer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(search(_:)), userInfo: searchText, repeats: false)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ProgressHUD.show()
        self.searchBar.text?.removeAll()
        self.searchBar.showsCancelButton = true
        self.dataController.search(text: "")
        self.collectionView.endEditing(true)
        ProgressHUD.dismiss()
    }
}

extension SearchViewController : DataControllerDelegate {
    
    func presenterDidUpdateData(presenter: DataController) {
        collectionView.reloadData()
        ProgressHUD.showSuccess()
    }
}
