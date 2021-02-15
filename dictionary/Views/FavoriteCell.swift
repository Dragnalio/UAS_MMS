//
//  FavoriteCell.swift
//  dictionary
//
//  Created by Handika Limanto on 14/02/21.
//

import UIKit

class FavoriteCell: UITableViewCell {

    @IBOutlet weak var wordTV: UILabel!
    @IBOutlet weak var definitionsTV: UILabel!
    
    func initView(_ word: Word){
        wordTV.text = word.word
        definitionsTV.text = word.definitions
    }

}
