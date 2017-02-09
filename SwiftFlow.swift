//
//  SwiftFlow.swift
//  SwiftFlow
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

import Foundation

// throw exception on invalid unwrap (in production only)

public func unwrap<T>(_ toUnwrap: T!, name: String? = nil,  file: String = #file, line: Int = #line ) -> T {
    #if !DEBUG
    if toUnwrap == nil {
        let exceptionName = name != nil ? "Forced unwrap of \(name) fail" : "Forced unwrap fail"
        _throw( NSException( name: NSExceptionName(rawValue: exceptionName), reason: "\(file), \(line)", userInfo: nil ) )
    }
    #endif
    return toUnwrap!
}

// an implementation of @sychronized to make acces to a section of code exclusive

private let synchronizedKeyLock = NSLock()
private var synchronizedSectionLocks = [String:NSLock]()

public func _synchronized( _ section: @escaping () -> (), key: String = "\(#file):\(#line)" ) {
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

// a take on shell-like custom threading operators after:
// http://ijoshsmith.com/2014/07/05/custom-threading-operator-in-swift/

private let _queue = DispatchQueue(label: "SwiftFlow", attributes: .concurrent)

public func | (left: @escaping () -> Void, right: @escaping () -> Void) {
    _queue.async() {
        left()
        DispatchQueue.main.async(execute: right)
    }
}

public func | <R> (left: @escaping () -> R, right: @escaping (_ result:R) -> Void) {
    _queue.async() {
        let result = left()
        DispatchQueue.main.async(execute: {
            right(result)
        })
    }
}

// dispatch groups { block } & { block } | { completion }
public func & (left: @escaping () -> Void, right: @escaping () -> Void) -> [() -> Void] {
    return [left, right]
}

public func & (left: [() -> Void], right: @escaping () -> Void) -> [() -> Void] {
    var out = left
    out.append( right )
    return out
}

public func | (left: [() -> Void], right: @escaping () -> Void) {
    let group = DispatchGroup()

    for block in left {
        __dispatch_group_async(group, _queue, block)
    }

    __dispatch_group_notify(group, DispatchQueue.main, right)
}

// parallel processing blocks with returns
public func & <R> (left: @escaping () -> R, right: @escaping () -> R) -> [() -> R] {
    return [left, right]
}

public func & <R> (left: [() -> R], right: @escaping () -> R) -> [() -> R] {
    var out = left
    out.append( right )
    return out
}

public func | <R> (left: [() -> R], right: @escaping (_ results:[R?]) -> Void) {
    let group = DispatchGroup()

    var results = Array<R!>()
    for _ in 0..<left.count {
        results += [nil]
    }

    for t in 0..<left.count {
        group.enter()
        _queue.async(execute: {
            results[t] = left[t]()
            group.leave()
        })
    }

    __dispatch_group_notify(group, DispatchQueue.main, {
        right(results)
    })
}
