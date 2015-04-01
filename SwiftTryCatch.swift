//
//  SwiftTryCatch.swift
//  SwiftTryCatch
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import Foundation

public func U<T>( toUnwrap: T!, file: String = __FILE__, line: Int = __LINE__ ) -> T {
    #if !DEBUG
    if toUnwrap == nil {
        _throw( NSException( name: "Forced unwrap fail", reason: "\(file), \(line)", userInfo: nil ) )
    }
    #endif
    return toUnwrap!
}

