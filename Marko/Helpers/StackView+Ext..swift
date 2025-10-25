//
//  StackView+Ext..swift
//  Marko
//
//  Created by Ivan on 11.10.2025.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(view: [UIView]) {
        
        view.forEach { child in
            addArrangedSubview(child)
        }
    }
}
