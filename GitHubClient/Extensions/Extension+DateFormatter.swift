//
//  Extension+DateFormatter.swift
//  GitHubClient
//
//  Created by usr01 on 23.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

extension DateFormatter {

    func getStringDate(date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
