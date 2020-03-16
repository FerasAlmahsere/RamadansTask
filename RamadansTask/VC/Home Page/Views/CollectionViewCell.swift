//
//  CollectionViewCell.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: CircularImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    

    func configure(viewModel: CollectionViewCellVM) {
        let model = viewModel.model

        userImage.setImage(pth: model.avatarURL, placeholder: UIImage(named: "avatar-placeholder"))
        userNameLabel.text = model.login
    }
}
