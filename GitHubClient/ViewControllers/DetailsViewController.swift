//
//  DetailsViewController.swift
//  GitHubClient
//
//  Created by usr01 on 22.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


let font = "HelveticaNeue"

class DetailsViewController: UIViewController {
    
    let dateFormatter = DateFormatter()
    var gitLink: String? = ""
    
    var presenter: DetailsViewPresenterProtocol!
    
    private lazy var avatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.lightText.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont(name: font, size: 22)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: font, size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = UIFont(name: font, size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: font, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var gitLinkButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.setImage(UIImage(named: "GitHub-logo.png"), for: .normal)
        button.setTitle("Open in GitHub", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        button.titleEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 2)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setContentCompressionResistancePriority(UILayoutPriority.init(rawValue: 1000), for: .horizontal)
        return button
        
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(avatarView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(languageLabel)
        view.addSubview(dateLabel)
        view.addSubview(gitLinkButton)
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func configureVC(with model: Item) {
        if let urlString = model.owner.avatarURL {
            avatarView.setCachedImage(urlString: urlString)
        }
        titleLabel.text = model.fullName
        descriptionLabel.text = model.itemDescription
        //        repoLinkLabel.text = model.htmlURL
        setURLTarget(urlString: model.htmlURL)
        if let language = model.language {
            languageLabel.text = "Language: " + language
        }
        dateLabel.text = "Updated at: " + DateFormatter().getStringDate(date: model.updatedAt)
        
    }
    
    
    
    private func setURLTarget(urlString: String) {
        guard let _ = URL(string: urlString) else {return}
        gitLink = urlString
        gitLinkButton.addTarget(self, action: #selector(openURL(_:)) , for: .allTouchEvents)
    }
    
    @objc private func openURL(_ sender: UIButton) {
        guard let url = URL(string: gitLink!) else {return}
        UIApplication.shared.open(url)
    }
    
    private func setupConstraints() {
        
        let topSeparator: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80))
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.darkText.cgColor , UIColor.white.cgColor ]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.3)
        gradient.locations = [0.0 , 1.0]
        gradient.frame = topSeparator.frame
        topSeparator.layer.insertSublayer(gradient, at: 0)//        topSeparator.backgroundColor = .darkText
        view.addSubview(topSeparator)
        view.sendSubviewToBack(topSeparator)
        
//        topSeparator.snp.makeConstraints { (make) in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo(20)
//        }
        
        avatarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(40)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview().inset(15)
            make.top.equalTo(avatarView.snp.bottom).offset(15)
            make.centerX.equalTo(avatarView.snp.centerX)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview().inset(15)
            make.top.equalTo(dateLabel.snp.bottom).offset(15)
            make.centerX.equalTo(avatarView.snp.centerX)
        }
        
        languageLabel.snp.makeConstraints { (make) in
            make.trailing.leading.equalToSuperview().inset(20)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
            make.bottom.lessThanOrEqualTo(gitLinkButton.snp.top).inset(10)
        }
        
        gitLinkButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview().offset(-18)
            
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
}


extension DetailsViewController: DetailsViewProtocol {
  
    func setImage(stringUrl: String?) {
        if let url = stringUrl {
             avatarView.setCachedImage(urlString: url)
        }
    }
    
    func configure(with title: String?, description: String?, date: String, language: String?, htmlURL: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        setURLTarget(urlString: htmlURL)
        languageLabel.text = language
        dateLabel.text = date
    }
    
   
    
    func configure(with: Item) {
        if let urlString = with.owner.avatarURL {
                    }
        titleLabel.text = with.fullName
        descriptionLabel.text = with.itemDescription
        //        repoLinkLabel.text = model.htmlURL
        setURLTarget(urlString: with.htmlURL)
        if let language = with.language {
            languageLabel.text = "Language: " + language
        }
        dateLabel.text = "Updated at: " + DateFormatter().getStringDate(date: with.updatedAt)
    }
    
    
    
}

