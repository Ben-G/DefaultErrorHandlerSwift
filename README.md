#Convenient Error Handling in Swift


Swift 2 introduced an error handling mechanism that includes [backwards compatibility with Objective-C](link to my post).

**This is great news, the new mechanism is a lot stricter.** Long gone are the days in which one could ignore errors by lavishly throwing `nil` at methods that expect a pointer to an `NSError` variable.

#Does Every Error Deserve an Individual Catch?

Swift will require you to provide an error handler when you call a method that `throws`, unless you resort to the `try?` or `try!` operator. Here's an example of `try!`:

```
try! NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
```
Using this unfaithful approach an unexpectedly occurring error will crash your app. Using `try!`, just as using forcefully unwrapped optionals, should be avoided in almost all cases.

Alternatively you can use `try?`, which will transform the result of the operation you are performing into an optional. A successful operation will yield a value, a failed operation will yield `nil`:

```
let data = try? NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
```
With this approach all details of an error that ocurred will be swallowed entirely which is suboptimal in many cases as well.

**But is it worth it writing a custom error handler for every error producing function you call? I don't think so.**

Many kinds of errors deserve your full attention, you can write code to recover from them or, at the very least, notify the user about unexpected behavior with a meaningful error message. 

Other errors are less important. You cannot recover from them with reasonable effort and they don't affect the user experience. The user will not want to be informed about them. Here are examples of errors that, in my opinion, fall into this category:

- Caching a downloaded image on disk fails
- Your app cannot connect to the ad service you are using

Depending on the complexity of your app, there might be hundreds of such operations. How can you avoid writing a custom error handlers for each of them without resorting to `try!`?

#A Good Compromise?

Can we strike a balance between convenience and due diligence? I believe so. In my latest side project I implemented a default error handler that deals with errors that, for one reason or another, don't deserve a custom error handler. 

This error handler doesn't swallow the error completely. Instead, it logs the errors using my analytics service. This behavior is useful for any type of error that might occur in my app. It's the largest common denominator of error handling.

This is what using the API looks like:

```
let errorHandler = ErrorHandler()

let fileContent = errorHandler.wrap {
    return try NSString(contentsOfFile: "doesNotExist", encoding: NSUTF8StringEncoding)
}
```

Here are the main characteristics:

- We wrap the call to call to the error producing function, along with the `try` keyword, into a closure that gets handed to `errorHandler.wrap`
- If the closure returns a value, then `errorHandler.wrap` will pass it through to its caller
- `errorHandler.wrap` always returns an optional type, indicating that the wrapped operation might fail and return `nil`

In the above example the `fileContent` variable has a type of `String?`.  We can use this variable in subsequent operations. While we need to check if the optional contains a value before using it, we can ignore the details of a potential error that was thrown. In this case `errorHandler.wrap` acts as a glorified version of `try?`.

In most cases I use the default error handler when calling functions without a return value. In these cases the value of the error handler becomes more obvious:

```
[...]
let errorHandler = ErrorHandler()

errorHandler.wrap {
	try cache.storeImage(image)
}
```
We can perform a failable operation without writing any code that deals with errors or optional return values, while still capturing details about errors that might occur.

#Implementation of the Default Error Handler

The implementation of the error handler is very slim, here's the entire code:

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

The `wrap` function takes a function that can `throw` and that can provide a return type. It executes the function within a `do`/`try` block. If the operation is successful it returns the return value of the function. If an error occurs the catch block calls the `logError` function and then returns `nil`.

The `logError` function should be customized to your needs - as an example I am printing the current stack trace along with the error message. In a production environment you would likely want to log these messages using an analytics service such as Fabric or Mixpanel.

#Conclusion

Good error handling is incredibly important for a good user experience - I wanted to make the process as easy as possible. Now my analytics dashboard will inform me about any unhandled error that occurs in production. Going from there I can improve error handling in my apps by adding custom handlers for the most frequent errors.

I definitely encourage you and myself to handle as many errors as sensible individually - but I believe there's a large number of potential errors that are suitable for this generic error handling scheme.

You can find the Source Code for this blog post [on GitHub](https://github.com/Ben-G/DefaultErrorHandlerSwift). 

How do you tackle error handling? I would love to hear from you!

##Acknowledgements

- Thanks to [`Result.materialize`](https://github.com/antitypical/Result/blob/master/Result/Result.swift#L153-L159) for inspiring my `wrap` function
- Thanks to [morganchen96](https://twitter.com/morganchen96) for providing feedback on a draft of this post