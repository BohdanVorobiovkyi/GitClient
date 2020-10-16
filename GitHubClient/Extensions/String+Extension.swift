//
//  String+Extension.swift
//  GitHubClient
//
//  Created by Богдан Воробйовський on 16.10.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}
