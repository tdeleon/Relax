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
- ``settingHeader(_:)``
- ``settingHeader(name:value:)-8po2n``
- ``settingHeader(name:value:)-4f2i6``
- ``addingHeader(_:)``
- ``addingHeader(name:value:)-86oq8``
- ``addingHeader(name:value:)-4bhc3``
- ``removingHeader(_:)-qd7o``
- ``removingHeader(_:)-1cn3v``

### Sending Requests

- ``send(session:autoResumeTask:parseHTTPStatusErrors:completion:)``
- ``send(decoder:session:autoResumeTask:parseHTTPStatusErrors:completion:)``

### Sending Requests Asynchronously

- ``send(session:parseHTTPStatusErrors:)-2v56r``
- ``send(decoder:session:parseHTTPStatusErrors:)-2nvfo``

### Sending Requests With a Publisher

- ``send(session:parseHTTPStatusErrors:)-926tl``
- ``send(decoder:session:parseHTTPStatusErrors:)-4i33g``
