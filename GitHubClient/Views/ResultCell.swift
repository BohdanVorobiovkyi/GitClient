//
//  ResultCell.swift
//  GitHubClient
//
//  Created by usr01 on 22.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

enum MocConstants {
    static let mocImage = UIImage(named: "GitHub-logo.png")
    static let font = UIFont(name: "HelveticaNeue", size: 16)
    static let topLogo = UIImage(named: "github-header.png")
    static let starImage = UIImage(named: "star.png")
}

class ResultCell: UICollectionViewCell {
    
    static let cellHeight: CGFloat = 90.0
    
    private lazy var avatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .clear
        makeRound(view: iv, cornerRadius: 10, borderWidth: 0, borderColor: .lightGray)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = MocConstants.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = MocConstants.font?.withSize(14)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var starView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = MocConstants.starImage
        iv.contentMode = .scaleAspectFit
        return iv
        
    }()
    
    private lazy var starsNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(UILayoutPriority.init(rawValue: 1000), for: .horizontal)
        label.textAlignment = .right
        label.font = MocConstants.font?.withSize(10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        languageLabel.text = ""
        avatarView.image = MocConstants.mocImage
    }
    
    func configureCell(model: Item) {
        titleLabel.text = model.fullName
        
        if let lang = model.language {
            languageLabel.text = "Language: \(String(describing: lang))"
        }
        if let urlString = model.owner.avatarURL {
            avatarView.setCachedImage(urlString: urlString)
        } else {
            avatarView.image = MocConstants.mocImage
        }
    
        starsNumberLabel.text = "\(model.stars)"
        
    }
    
    private func setupViews() {
        backgroundColor = .white
        makeRound(view: self, cornerRadius: 10, borderWidth: 0, borderColor: .lightText)
        self.addSubview(avatarView)
        self.addSubview(titleLabel)
        self.addSubview(languageLabel)
        self.addSubview(starView)
        self.addSubview(starsNumberLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        avatarView.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview().inset(15)
            make.height.width.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(10)
            make.leading.equalTo(avatarView.snp.trailing).offset(15)
            make.top.equalTo(avatarView.snp.top).inset(2)
        }
        
        languageLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(avatarView.snp.bottom).inset(2)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(starsNumberLabel.snp.leading).offset(-2)
        }
        
        starView.snp.makeConstraints { (make) in

            make.centerY.equalTo(starsNumberLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.height.width.equalTo(14)
            
        }
        
        starsNumberLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(starView.snp.leading)
            make.centerY.equalTo(languageLabel.snp.centerY)
                    make.height.equalTo(20)
        }
    }
}

