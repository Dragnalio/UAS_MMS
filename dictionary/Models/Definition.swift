//
//  Definition.swift
//  dictionary
//
//  Created by Handika Limanto on 14/02/21.
//

import Foundation

class Definition{
    
    var type: String
    var definition: String
    var imgData: Data?
    
    init(_ type: String, _ definition: String, _ imgData: Data?) {
        self.type = type
        self.definition = definition
        self.imgData = imgData
    }
}
