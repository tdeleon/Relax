# ``Relax/QueryItems/Builder``

A result builder that you use to compose a ``QueryItems`` instance.

## Overview

This result builder combines any number of ``QueryItem``, `(String, CustomStringConvertible?)`, or `URLQueryItem`
instances into a single ``QueryItems`` instance, with support for conditionals.

Each component will be converted to a `URLQueryItem` and appended to an array. You can use this builder in any closure
with the `@QueryItems.Builder` attribute.

- Note: Although not required, you can use ``QueryItem`` structure to better organize and pre-define query items which
are used often in your requests.

```swift
// Produces a URLQueryItem with a name of "sort" and value of "true"
QueryItems {
    QueryItem("sort": true)
}

// Acceptable values for creating items include `QueryItem`, `URLQueryItem`, or a tuple of
// `(String, CustomStringConvertible?)`
QueryItems {
    QueryItem("sort": true)
    URLQueryItem(name: "filter", value: "false")
    ("search", "abcd")
}
```
