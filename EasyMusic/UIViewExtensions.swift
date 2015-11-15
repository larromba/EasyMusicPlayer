//
//  UIViewExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIView {
    func loadXib() {
        let view = createViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
    
    func nibView() -> UIView? {
        return subviews.first
    }
    
    private func createViewFromNib() -> UIView! {
        let nib = UINib(nibName: self.className(), bundle: NSBundle.safeMainBundle())
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
}