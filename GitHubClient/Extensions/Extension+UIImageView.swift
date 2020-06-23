//
//  Extension+UIImageView.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setCachedImage( urlString: String) {
        self.kf.indicatorType = .activity
        guard let url = URL.init(string: urlString) else {
            print("Can't load this url ", urlString)
            return
        }
        let cacheKey = urlString
        let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
        let cache = ImageCache.default
        let cached = cache.isCached(forKey: cacheKey)
        if cached {
            cache.retrieveImage(forKey: cacheKey) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.image = value.image
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let processor = DownsamplingImageProcessor(size: CGSize(width: 60, height: 60))
            
            self.kf.setImage(with: resource, placeholder: UIImage(named: "GitHub-logo.png"), options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.3)),
                .cacheSerializer(DefaultCacheSerializer.default)
            ]) {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
