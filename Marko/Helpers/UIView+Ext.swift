//
//  UIView+Ext.swift
//  Marko
//
//  Created by Ivan on 02.02.2026.
//

import UIKit

extension UIView {

    func addSubviews(views: [UIView]) {

        views.forEach { child in
            self.addSubview(child)
        }

    }

}
