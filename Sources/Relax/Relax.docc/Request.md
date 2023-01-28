# ``Relax/Request``

## Topics

### Creating a Request

- ``init(_:url:configuration:properties:)``
- ``init(_:parent:configuration:properties:)``
- ``RequestBuilder``

### Request Attributes

- ``httpMethod-swift.property``
- ``url``
- ``urlRequest``
- ``configuration-swift.property``
- ``headers``
- ``queryItems``
- ``pathComponents``
- ``body``
- ``HTTPMethod-swift.struct``

### Modifying a Request

- ``setting(_:)-2ftno``
- ``setting(_:)-s95b``
- ``adding(_:)``

### Modifying Request Headers

- ``settingHeader(_:)``
- ``settingHeader(name:value:)-8po2n``
- ``settingHeader(name:value:)-4f2i6``
- ``addingHeader(_:)``
- ``addingHeader(name:value:)-86oq8``
- ``addingHeader(name:value:)-4bhc3``
- ``removingHeader(_:)-qd7o``
- ``removingHeader(_:)-1cn3v``

### Sending Requests Asynchronously

- ``send(session:parseHTTPStatusErrors:)-51tcd``
- ``send(decoder:session:parseHTTPStatusErrors:)-2nvfo``
- ``AsyncResponse``
- ``AsyncModelResponse``

### Sending Requests with a Publisher

- ``send(session:parseHTTPStatusErrors:)-2a2id``
- ``send(decoder:session:parseHTTPStatusErrors:)-4i33g``
- ``PublisherResponse``
- ``PublisherModelResponse``

### Sending Requests with a Completion Handler

- ``send(session:autoResumeTask:parseHTTPStatusErrors:completion:)``
- ``send(decoder:session:parseHTTPStatusErrors:completion:)``
- ``Response``
- ``ResponseModel``
- ``Completion``
- ``ModelCompletion``
