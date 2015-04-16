## SwiftFlow

Many have considered the ommision of exceptions from Swift an oversight and this doesn't look likely to change soon. Thankfully this is an oversight that is quite easilly rectified as others [have](https://github.com/williamFalcon/SwiftFlow), [observed](https://github.com/kongtomorrow/TryCatchFinally-Swift).

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

### Other Swift flow constructs

SwiftFlow has been renamed SwiftFlow as it now includes a couple of other flow of control primitives. First two implementations of @sychronised for Swift. The first is can lock a piece of code against an object as per Objective-C.

```objc
void _synchronized( id object, void (^syncBlock)() ) {
    @synchronized( object ) {
        syncBlock();
    }
}
```

The second locks only a section of code but gloabally using the file and line number:

```swift
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
```

### Some threading operators

As an excercise I've added in my take on Josh Smith's 
[custom threading operators](http://ijoshsmith.com/2014/07/05/custom-threading-operator-in-swift/)
for background process (adding dispatch groups.) The syntax is taken from UNIX shell.
For example, the following processes the first group in a background thread then
passes the result back to the main thread to print it out:

```Swift
    {
        // async background
        return 99
    } | {
        // main thread again
        (result:Int) in
        println("\(result)")
    };
```

This works for thread groups as well where multiple blocks are executed in 
parallel again following shell syntax where multiple parallel blocks are
separated by the & operator. The array of their results are passed back 
to the main thread using the pipe operator as before:

```Swift
    {
        // thread 1
        return 77
    } & {
        // thread 2
        return 88
    } & {
        // thread 3
        return 99
    } | {
        // main thread
        (results:[Int!]) in
        println("\(results)")
    };
```

There are also & and | operators for when no value is passed between the blocks.
The semicolon is necessary as is one on the line previous to using these
operators.

### Public domain License

This code is in the public domain. Just don't sue me ok?
