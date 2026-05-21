# Cadova Viewer Kit
Note: The library does not work with currently public versions of Cadova Viewer (<= 0.3). It will **if** or when the needed changes are merged 

CadovaViewerKit is a library for [Cadova](https://github.com/tomasf/Cadova) to open in-memory models in [Cadova Viewer](https://github.com/tomasf/CadovaViewer)

It only works for models in .3mf format, which is the [Default format](https://github.com/tomasf/Cadova/wiki/Core-Concepts:-5.-Model-and-Project#format) in Cadova.

## Installation

Integrate CadovaViewerKit into your project with the Swift Package Manager by adding it as a dependency in your `Package.swift` file:

```swift
.package(url: "https://github.com/JPBeltman/CadovaViewerKit", .upToNextMinor(from: "0.1.0"))
```

## Usage
```swift
import CadovaViewerKit

let modelFile = try await ModelFileGenerator.build(named: "my-model", options: .format3D(.threeMF)) {
    Box(x: 10, y: 10, z: 5)
}

try await modelFile.preview()
```
