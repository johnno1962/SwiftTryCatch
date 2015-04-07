//
//  SwiftFlow.m
//  SwiftFlow
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

#import "SwiftFlow.h"

static NSString *kLastExceptionKey = @"lastTryCatchException";

void _try( void (^tryBlock)() ) {
    [[NSThread currentThread].threadDictionary removeObjectForKey:kLastExceptionKey];
    @try {
        tryBlock();
    }
    @catch (NSException *e) {
        [NSThread currentThread].threadDictionary[kLastExceptionKey] = e;
    }
}

void _catch( void (^catchBlock)( NSException *e ) ) {
    NSException *e = [NSThread currentThread].threadDictionary[kLastExceptionKey];
    if ( e ) {
        catchBlock( e );
    }
}

void _throw( NSException *e ) {
    @try {
        @throw e;
    }
    @catch ( NSException *e ) {
        NSLog( @"%@ %@\n%@", e.name, e.reason, e.callStackSymbols );
        @throw e;
    }
}

void _synchronized( id object, void (^syncBlock)() ) {
    @synchronized( object ) {
        syncBlock();
    }
}

