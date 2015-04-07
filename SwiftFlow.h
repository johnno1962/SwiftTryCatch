//
//  SwiftFlow.h
//  SwiftFlow
//
//  Created by John Holdsworth on 31/03/2015.
//  Copyright (c) 2015 John Holdsworth. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void _try( void (^tryBlock)() );
extern void _catch( void (^catchBlock)( NSException *e ) );
extern void _throw( NSException *e );
extern void _synchronized( id object, void (^syncBlock)() );
