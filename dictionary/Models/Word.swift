//
//  Word.swift
//  dictionary
//
//  Created by Handika Limanto on 15/02/21.
//

import Foundation

class Word{
    
    var word: String
    var definitions: String!
    
    init(_ word: String, _ definitions: [Definition]) {
        self.word = word
        let text = getDefinitions(definitions)
        self.definitions = text
    }
    init(_ word: String, _ definitions: String) {
        self.word = word.uppercased()
        self.definitions = definitions
    }
    func getDefinitions(_ definitions: [Definition]) -> String{
        var text = ""
        var index = 0
        let size = definitions.count
        for definition in definitions{
            index = index + 1
            text += "(\(index)) \(definition.type) - \(definition.definition)"
            if index < size{
                text += "\n"
            }
        }
        return text
    }
    
}
