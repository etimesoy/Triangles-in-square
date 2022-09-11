//
//  UIViewController+Ext.swift
//  Triangles in square
//
//  Created by Руслан on 11.09.2022.
//

import UIKit

extension UIViewController {
    var statusWithNavigationBarsHeight: CGFloat {
        UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.maxY ?? 0)
    }
}
