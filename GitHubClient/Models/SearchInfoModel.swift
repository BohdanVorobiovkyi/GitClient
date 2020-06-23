//
//  SearchInfoModel.swift
//  GitHubClient
//
//  Created by usr01 on 19.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

struct SearchInfoModel: Decodable {
    let totalCount: Int?
    let incompleteResults: Bool?
    let items: [Item]?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}






