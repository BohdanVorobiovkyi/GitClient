//
//  ItemModel.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

struct Item: Decodable {
    let id: Int
    let fullName: String?
    let owner: Owner
    let htmlURL: String
    let itemDescription: String?
    let forks: Int
    let createdAt, updatedAt: Date
    let stars: Int
    //    let pushedAt: Date?
    let language: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case stars = "stargazers_count"
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case itemDescription = "description"
        case forks
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        //        case pushedAt = "pushed_at"
        case language
    }
}

