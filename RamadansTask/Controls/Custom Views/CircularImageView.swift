//
//  CircularImageView.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import UIKit

@IBDesignable
class CircularImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup(){
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true
    }
}
