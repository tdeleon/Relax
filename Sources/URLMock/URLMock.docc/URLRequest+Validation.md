# ``Foundation/URLRequest``

An extension provided to assist in validating requests.

## Overview

Use these convenience methods on the `URLRequest` provided in the ``MockResponse/onReceive`` closure to validate that
the request received is correct.

>Note: The `validate()` methods use `XCTAssert` for validation, and are intended for use only in testing.

## Topics

### Validating Request Query Items

- ``Foundation/URLRequest/queryItems``
- ``Foundation/URLRequest/validateQueryItems(match:)``
- ``Foundation/URLRequest/validateQueryItemNames(contain:doNotContain:)``

### Validating Request Headers

- ``Foundation/URLRequest/validateHeaders(match:)``
- ``Foundation/URLRequest/validateHeaderNames(contain:doNotContain:)``

### Validating Request Body
- ``Foundation/URLRequest/validateBody(matches:)-9rwxp``
- ``Foundation/URLRequest/validateBody(matches:decoder:)``
- ``Foundation/URLRequest/validateBody(matches:)-5ihb5``
