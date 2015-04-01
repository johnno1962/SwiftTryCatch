## SwiftTryCatch

Many have considered the ommision of exceptions from Swift an oversight and this doesn't look likely to change soon. Thankfully this is an oversight that is quite easilly rectified as others [have](https://github.com/williamFalcon/SwiftTryCatch), [observed](https://github.com/kongtomorrow/TryCatchFinally-Swift).

I've extended this slightly to deal with the mixed blessing that is dealing with unwrapping optionals. `"If let"` is all very well (crash avoided) but what about the "else" clause which is often left out? How can it report the error to aid in debugging when a nil optional is encountered within a function called by a function called by a function. What if it has to return a value? Is the only option really to crash the application? Perhaps every return should be of a [result type](https://gist.github.com/landonf/539354d19175c9e5239b) though this clutters source all the way down the stack and somewhere the error has to be handled and reported.

Why not just use exceptions? The code is minimal though it requires a small Objective-C stub.

```objc
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
```

Thereafter, you can use these functions pretty much as you would in Objective-C (see the project's tests for examples)

```swift
_try {
    // involved code that might fail (unwrapping?) somewhere
}
_catch {
    (exception: NSException) in
    // handle error
}
// _finally not implemented as code after the try catch will always be executed. 
```

To throw exceptions on failed unwrap include the following code in your Swift

```swift
public func U<T>( toUnwrap: T!, file: String = __FILE__, line: Int = __LINE__ ) -> T {
    #if !DEBUG
    if toUnwrap == nil {
        _throw( NSException( name: "Forced unwrap fail", reason: "\(file), \(line)", userInfo: nil ) )
    }
    #endif
    return toUnwrap!
}
```

Use `U(optional)` everywhere you might be forced to use `"!"`. This will retain the debuggability of failed unwraps but gives some protection from an instant crash in production (provided the code is wrapped at entry in a `_catch{}` (you might want to consider using "-fobjc-arc-exceptions" to have objects release correctly when exceptions are thrown.)

This might seem a recipie for encouraging lazy coding practice but in reality unless you can provide a value for a property in an initiliser optionals will crop up all over your code. Coping with every conceivable case where an optional could  be nil dilutes the content of code dealing with what are often exceptional cases.

### MIT License

Copyright (C) 2015 John Holdsworth

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial 
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
