#Implementing a Default Error Handler in Swift


Swift 2 introduced an error handling mechanism to the maturing programming language and even provides [backwards compatibility with the Objective-C error handling scheme, used throughout all of the Cocoa frameworks](link to my post).

**This is great news - at the same time the new mechanism is a lot stricter.** Long gone are the days in which we could ignore errors by lavishly throwing `nil` at methods that expect a pointer to an `NSError` variable.

The compiler now forces us to deal with potential errors. Since we're now forced to handle errors you might take a dangerous shortcut when calling methods that *never should* throw errors or that produce errors that you cannot handle elegantly:

```
try! NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
```
Initially this might feel similarly convenient as passing `nil` to the error producing methods in Objective-C, but it causes just the opposite behavior. Instead of ignoring the error your app will crash.

Using `try!`, just as using forcefully unwrapping of Optionals, should be avoided in almost all cases.

**But is it worth it writing a custom error handler for every error producing method we call? I don't think so.**

Many kinds of errors deserve our full attention, we can write code to recover from them or, at the very least, notify the user about unexpected behavior with a meaningful error message. 

Other errors are less important. We cannot recover from them and they don't affect the user experience, thus the user won't want to be informed about them. Here are examples of errors that, in my opinion, fall into this catogory:

- You try to cache a downloaded image on disk, but the disk is full
- Your app cannot connect to the ad service you are using

How can we deal with these types of operations that might produce errors in Swift?

#A Good Compromise?

Can we strike a balance between convenience and due diligence? **I believe so**. In my latest side project I attempted doing so by providing a default error handler that deals with errors that for one reason or another don't deserve my full attention in the form of a custom error handler. Instead of swallowing the error completely, as passing `nil` as error reference in Objective-C used to do, the handler provides code that is useful for any error independent of its type: it logs the error.

This is what the API looks like to the consumer:

```
let errorHandler = ErrorHandler()

let fileContent = errorHandler.wrap {
    return try NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
}
```

Here are the main characteristics:

- We wrap the call to call to the error producing function along with the `try` keyword into a closure that gets handed to `errorHandler.wrap`
- If the closure returns a value, then `errorHandler.wrap` will pass it back to its caller
- `errorHandler.wrap` always returns an optional type, indicating that the wrapped operation might fail and return nil

In the above example the `fileContent` variable has a type of `String?` and we can use it in subsequent operations, ignoring the details of a potential error that was thrown.

#Implementation of the Default Error Handler

Here's the entire code that goes into implementing the error handler:

```
class ErrorHandler {
    
    func wrap<ReturnType>(@noescape f: () throws -> ReturnType?) -> ReturnType? {
        do {
            return try f()
        } catch let error {
            logError(error)
            return nil
        }
    }
    
    func logError(error: ErrorType) {
        let stackSymbols = NSThread.callStackSymbols()
        print("Error: \(error) \n Stack Symbols: \(stackSymbols)")
    }
    
}
```

The `wrap` function takes a function that can `throw` and that can provide a return type. It exectures the function within a `do`/`try` block. If the operation is successful it returns the return value of the function. If an error ocurrs the catch block calls the `logError` function and then returns `nil`.

The `logError` function should be customized to your needs - as an example I am printing the current stack trace along with the error messages. In a production environment I would likely want to log these messages using an analytics service such as Fabric or Mixpanel.


