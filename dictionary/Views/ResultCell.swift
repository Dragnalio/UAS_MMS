//
//  Cell.swift
//  dictionary
//
//  Created by Handika Limanto on 14/02/21.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var resultImgIV: UIImageView!
    @IBOutlet weak var resultTypeTV: UILabel!
    @IBOutlet weak var resultDefinitionTV: UILabel!
    
    func initView(_ definition: Definition){
        if let data = definition.imgData{
            resultImgIV.image = UIImage(data: data)
        } else {
            resultImgIV.image = UIImage(named: "imgnotfound.png")
        }
        resultTypeTV.text = definition.type
        resultDefinitionTV.text = definition.definition
    }

}
