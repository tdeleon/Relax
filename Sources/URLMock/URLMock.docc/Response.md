# ``MockResponse/Response``

## Topics

### Response Properties

- ``httpURLResponse``
- ``data``
- ``error``

### Creating a Response

- ``init(httpURLResponse:data:error:)``
- ``init(statusCode:data:error:for:)``

### Creating a JSON Response

- ``init(model:encoder:statusCode:error:for:)``
- ``init(jsonObject:jsonWritingOptions:statusCode:error:for:)``

### Creating an Error Response

- ``init(code:for:)``
- ``init(httpErrorType:data:for:)``
- ``init(requestError:data:)``
