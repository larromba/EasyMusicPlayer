//
//  UIStoryboardExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 16/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func main() -> UIStoryboard {
        let storyboard = UIStoryboard(name: Constant.Storyboard.Player, bundle: nil)
        return storyboard
    }
}
