//
//  UIViewExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIView {
    public func loadXib() {
        let view = createViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    public func nibView() -> UIView? {
        return subviews.first
    }
    
    // MARK: - Private
    
    fileprivate func createViewFromNib() -> UIView {
        let nib = UINib(nibName: self.className(), bundle: Bundle.safeMainBundle())
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}
