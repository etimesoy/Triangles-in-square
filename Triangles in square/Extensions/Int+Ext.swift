//
//  Int+Ext.swift
//  Triangles in square
//
//  Created by Руслан on 10.09.2022.
//

import Foundation

extension Int {
    var isPowerOfTwo: Bool {
        return (self > 0) && (self & (self - 1) == 0)
    }
}
