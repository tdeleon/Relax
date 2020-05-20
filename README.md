
<h1 style="text-align: center;"><img src="https://user-images.githubusercontent.com/3507743/82412732-08c9c900-9a29-11ea-9eb4-0f7caea45e6e.png" height="60" style="vertical-align: middle; padding-right: 20px">Relax</h1>

---

![GitHub](https://img.shields.io/github/license/tdeleon/Relax)
[![Swift](https://img.shields.io/badge/Swift-5.2-brightgreen.svg?colorA=orange&colorB=4E4E4E)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://swift.org/package-manager/)
[![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-lightgrey)](https://swift.org)
![Test](https://github.com/tdeleon/Relax/workflows/Test/badge.svg?branch=master)


_A Protocol-Oriented Swift library for building REST client requests_

## Overview

Relax is a client library for defining REST services and requests, built on the concept of [_Protocol Oriented Programming_](https://developer.apple.com/videos/play/wwdc2015/408/). This means that it is largely built with protocols, allowing
for a great deal of flexibility in it's use.

### Features

- Simple - based on protocols
- Works directly on URLSession, for best performance and low overhead
- Allows for customization when desired (specify your own URLSession; manually `resume()` or `cancel()` URLSessionTasks as needed)
- Helps organize complex REST API request
- Support for Combine (on available platforms)

### Platforms

Relax is available on all Swift supported platforms, including:
- macOS
- iOS
- tvOS
- watchOS
- Linux

## Getting Started

### Adding to a Project
Relax can be added to projects using the Swift Package Manager, or added as a git submodule.

#### Swift Package Manager
In _Package.swift_:

1. Add to the package dependencies array

    ```
    dependencies: [
        .package(url: "https://github.com/tdeleon/Relax.git", from: "1.0.0")
    ]
    ```
    
2. Add _Relax_ to your target's dependencies array

    ```
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["Relax"])
    ]
    ```

### Usage

Import the Relax framework where it will be used
```
import Relax
```

## Concepts

## Examples
