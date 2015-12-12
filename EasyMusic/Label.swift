//
//  Label.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class Label: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            font = font.fontWithSize(font.pointSize * 2.0)
        }
    }
}