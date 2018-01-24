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
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func nibView() -> UIView? {
        return subviews.first
    }
    
    // MARK: - Private
    
    private func createViewFromNib() -> UIView {
        let nib = UINib(nibName: "\(classForCoder)", bundle: Bundle.safeMainBundle())
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("can't load view for \(self)")
        }
        return view
    }
}
