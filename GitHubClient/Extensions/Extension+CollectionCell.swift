//
//  Extension+CollectionCell.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    func makeRound(view : UIView , cornerRadius : CGFloat , borderWidth : CGFloat , borderColor : UIColor){
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
    }
}
