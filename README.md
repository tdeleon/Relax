
<h1 style="text-align: center;"><img src="https://user-images.githubusercontent.com/3507743/82412732-08c9c900-9a29-11ea-9eb4-0f7caea45e6e.png" height="60" style="vertical-align: middle; padding-right: 20px">Relax</h1>

---

[![License](https://img.shields.io/github/license/tdeleon/Relax)](https://github.com/tdeleon/Relax/blob/master/LICENSE)
[![Swift](https://img.shields.io/badge/Swift-5.7-brightgreen.svg?colorA=orange&colorB=4E4E4E)](https://swift.org)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20%7C%20Windows-blue)](https://www.swift.org/platform-support/)
[![Test](https://github.com/tdeleon/Relax/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/tdeleon/Relax/actions/workflows/test.yml?query=branch%3Amain++)

*Declaratively build and send client requests for REST APIs.*

## Overview

![Relax logo](RelaxLogo.png)

Relax provides a way to declaratively define and organize client HTTP requests for REST APIs. The framework is
lightweight built on protocols, easily allowing you to structure your requests for even the most complex REST APIs.

### Full Reference Documentation

https://swiftpackageindex.com/tdeleon/Relax/2.0.0/documentation/Relax

### Features

- **Lightweight:** built on protocols, works directly on URLSession for low overhead
- **Declarative syntax:** using [result builders](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630),
allows for quickly and easily organizing requests to match any structure of REST API.
- **Modern:** Supports [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
(`async`/`await`) and [Combine](https://developer.apple.com/documentation/combine) (on macOS/iOS/watchOS/tvOS).

### Supported Platforms

Available for all Swift (5.7+) platforms, including:

| Platform | Minimum Version |
|----------|-----------------|
| macOS    | 12.0            |
| iOS      | 14.0            |
| watchOS  | 7.0             |
| tvOS     | 14.0            |
| Linux    | Swift 5.7*      |
| Windows  | Swift 5.7*      |

*Works on any version where Swift 5.7 is supported.

### Getting Started

Relax supports the [Swift Package Manager](https://www.swift.org/package-manager/). To integrate in your project-

1. Add the following to the **package** dependencies in the *Package.swift* manifest file:

    ```swift
    dependencies: [
        .package(url: "https://github.com/tdeleon/Relax.git", from: "2.0.0")
    ]
    ```

2. Add *Relax* to the **target** dependencies:

    ```swift
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["Relax"])
    ]
    ```

In files where you will be using Relax, import the framework:

```swift
import Relax
```

To get started using Relax, see the [full documentation](https://swiftpackageindex.com/tdeleon/Relax/2.0.0/documentation/Relax
).
