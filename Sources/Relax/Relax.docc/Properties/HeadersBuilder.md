# ``Relax/Headers/Builder``

A result builder that you use to compose a ``Headers`` instance.

## Overview

This result builder combines any number of ``Header``, `[String: String]`, or `(String: String)` instances into a
single ``Headers`` instance, with support for conditionals.

Each component will be converted to a dictionary and appended to each other incrementally, from top to bottom. If a
a later value is set which has the same key as a previous entry, the value will be appended to the previous using a ","
character. You can use this builder in any closure with the @Headers.Builder attribute.

- Note: Although not required, you can use the ``Header`` structure to better organize and pre-define headers which are
used often in your requests.

```swift
// Sets a single header; the raw value in the request will be 'Cache-Control: no-cache'.
Headers {
    Header.cacheControl("no-cache")
}

// Set the same header using a dictionary instead
Headers {
    ["Cache-Control": "no-cache"]
}

// Setting multiple headers, using mixed types
Headers {
    Header.cacheControl("no-cache")
    ["ContentType": "application/json"]
}

// Setting multiple headers, with the same value.
// The result will be 'Accept: application/json,text/plain'
Headers {
    Header.accept(.applicationJSON)
    Header.accept(.textPlain)
}
```
