//
//  UITextField+Ext.swift
//  Triangles in square
//
//  Created by Руслан on 10.09.2022.
//

import UIKit

private final class InsetsTextField: UITextField {

    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("Not intended for use from a NIB")
    }

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds.inset(by: insets))
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds.inset(by: insets))
    }
}

extension UITextField {
    static func textFieldWithInsets(_ insets: UIEdgeInsets) -> UITextField {
        return InsetsTextField(insets: insets)
    }
}
