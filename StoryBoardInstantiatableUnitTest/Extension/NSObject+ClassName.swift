//
//  NSObject+ClassName.swift
//  StoryBoardInstantiatableUnitTest
//
//  Created by TakkuMattsu on 2017/10/08.
//  Copyright © 2017年 TakkuMattsu. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}
