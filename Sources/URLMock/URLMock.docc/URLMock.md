# ``URLMock/URLMock``

## Topics

### Providing a Response

- ``response``

### Creating a Mocked Session

- ``session(configuration:delegate:delegateQueue:mockResponse:)``
- ``session(configuration:delegate:delegateQueue:response:)``

### URLProtocol Methods

These methods are implemented in order to subclass `URLProtocol`. They will be called by `URLSession` when `URLMock` is
set as one of the `URLSessionConfiguration.protocolClasses`.

- ``canInit(with:)``
- ``canonicalRequest(for:)``
- ``startLoading()``
- ``stopLoading()``
