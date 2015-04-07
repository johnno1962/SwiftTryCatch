//
//  SwiftFlow.swift
//  SwiftFlow
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import Foundation

// throw exception on invalid unwrap (in production only)

public func U<T>( toUnwrap: T!, name: String? = nil,  file: String = __FILE__, line: Int = __LINE__ ) -> T {
    #if !DEBUG
    if toUnwrap == nil {
        let exceptionName = name != nil ? "Forced unwrap of \(name) fail" : "Forced unwrap fail"
        _throw( NSException( name: exceptionName, reason: "\(file), \(line)", userInfo: nil ) )
    }
    #endif
    return toUnwrap!
}

// an implementation of @sychronized to make acces to a section of code exclusive

private let synchronizedKeyLock = NSLock()
private var synchronizedSectionLocks = [String:NSLock]()

public func _synchronized( section: () -> (), key: String = "\(__FILE__):\(__LINE__)" ) {
    synchronizedKeyLock.lock()
    if synchronizedSectionLocks[key] == nil {
        synchronizedSectionLocks[key] = NSLock()
    }
    synchronizedKeyLock.unlock()
    if let sectionLock = synchronizedSectionLocks[key] {
        sectionLock.lock()
        _try {
            section()
            sectionLock.unlock()
        }
        _catch {
            (exception) in
            sectionLock.unlock()
            _throw( exception )
        }
    }
}

// a take on custom threading operators from
// http://ijoshsmith.com/2014/07/05/custom-threading-operator-in-swift/

private let _queue = dispatch_queue_create("SwiftFlow", DISPATCH_QUEUE_CONCURRENT)

public func | (left: () -> Void, right: () -> Void) {
    dispatch_async(_queue) {
        left()
        dispatch_async(dispatch_get_main_queue(), right)
    }
}

public func | <R> (left: () -> R, right: (result:R) -> Void) {
    dispatch_async(_queue) {
        let result = left()
        dispatch_async(dispatch_get_main_queue(), {
            right(result:result)
        })
    }
}

// dispatch groups { block } & { block } | { completion }
public func & (left: () -> Void, right: () -> Void) -> [() -> Void] {
    return [left, right]
}

public func & (left: [() -> Void], right: () -> Void) -> [() -> Void] {
    var out = left
    out.append( right )
    return out
}

public func | (left: [() -> Void], right: () -> Void) {
    let group = dispatch_group_create()

    for block in left {
        dispatch_group_async(group, _queue, block)
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), right)
}

// parallel processing blocks with returns
public func & <R> (left: () -> R, right: () -> R) -> [() -> R] {
    return [left, right]
}

public func & <R> (left: [() -> R], right: () -> R) -> [() -> R] {
    var out = left
    out.append( right )
    return out
}

public func | <R> (left: [() -> R], right: (results:[R!]) -> Void) {
    let group = dispatch_group_create()

    var results = Array<R!>()
    for t in 0..<left.count {
        results += [nil]
    }

    for t in 0..<left.count {
        dispatch_group_enter(group)
        dispatch_async(_queue, {
            results[t] = left[t]()
            dispatch_group_leave(group)
        })
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), {
        right(results: results)
    })
}
