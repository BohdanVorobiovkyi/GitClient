//
//  Extension+JSONDecoder.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

    func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }

