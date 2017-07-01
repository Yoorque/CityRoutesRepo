//
//  CustomDetailCell.swift
//  NewCityRoutes
//
//  Created by Dusan Juranovic on 3/9/17.
//  Copyright © 2017 Dusan Juranovic. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet var selectionImage: UIImageView!
    @IBOutlet var borderView: UIView!
    @IBOutlet var customCellImageView: UIImageView!
    @IBOutlet var direction: UILabel!
    @IBOutlet var lineNumber: UILabel!
    
    var model: Model? {
        didSet {
            customCellImageView.image = model?.image
            borderView.layer.borderColor = model?.color.cgColor
            borderView.backgroundColor = model?.color.withAlphaComponent(0.1)
            lineNumber.text = model?.lineNumber
            lineNumber.textColor = UIColor.white
            direction.text = model?.direction
            lineNumber.backgroundColor = model?.color.withAlphaComponent(0.5)
            lineNumber.layer.masksToBounds = true
            lineNumber.layer.cornerRadius = 15
        }
    }
    
    var modelRelation: ModelRelation? {
        didSet {
            customCellImageView.image = modelRelation?.image
            lineNumber.textColor = UIColor.white
            lineNumber.text = modelRelation?.lineNumber
            direction.text = (modelRelation?.directionFrom)! + "-" + (modelRelation?.directionTo)!
            lineNumber.backgroundColor = modelRelation?.color.withAlphaComponent(0.5)
            lineNumber.layer.masksToBounds = true
            lineNumber.layer.cornerRadius = 15
        }
    }
}

extension DetailTableViewCell {
    struct Model {
        let lineNumber: String
        let direction: String
        let image: UIImage
        let color: UIColor
        
        init(route: Routes, transport: String) {
            self.lineNumber = route.ref
            self.image = UIImage(named: transport)!
            self.color = UIColor.color(forTransport: transport)
            self.direction = language == "latin" ? "Both directions available" : "Оба смера"
        }
    }
    
    struct ModelRelation {
        
        let lineNumber: String
        let directionFrom: String
        let directionTo: String
        let image: UIImage
        let color: UIColor
        
        init(relation: Relations, transport: String) {
            self.directionFrom = language == "latin" ? relation.reltags.fromSrLatn : relation.reltags.from
            self.directionTo = language == "latin" ? relation.reltags.toSrLatn : relation.reltags.to
            self.lineNumber = relation.reltags.reltagRef
            self.image = UIImage(named: transport)!
            self.color = UIColor.color(forTransport: transport)
            
        }
    }
    
}
