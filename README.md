# StaticInternalSwiftSyntaxParser

This is a distribution of `lib_InternalSwiftSyntaxParser.dylib` built
statically. This allows you to create a self contained portable binary
that depends on [`swift-syntax`][swift-syntax] instead of having to
depend on your specific Xcode version and path, or distribute the
library alongside your tool.

# Usage

See [the releases
page](https://github.com/keith/StaticInternalSwiftSyntaxParser/releases)
to get the right version of the library for your version of Xcode and
[`swift-syntax`][swift-syntax].

With Swift Package Manager you can use the `.binaryTarget` type with
this:

```swift
targets: [
    // Some targets
    .binaryTarget(
        name: "lib_InternalSwiftSyntaxParser",
        url: "See releases page",
        checksum: "See releases page"
    ),
],
```

Then add `lib_InternalSwiftSyntaxParser` to the `dependencies` of
another target.

If you want to use this without Swift Package Manager you can download
the xcframework and use the internal
`lib_InternalSwiftSyntaxParser.framework` however you'd normally include
dependencies.

Note: because of [this bug](https://bugs.swift.org/browse/SR-15802) if
you want to depend on this target in SwiftPM and target multiple
architectures in a single build, you must only depend on it from top
level targets such as a test or executable target.

## Building

To create a new release for this project follow these steps:

- Clone [`apple/swift`](https://github.com/apple/swift) and checkout the
  branch you want using the `update-checkout` script as described in
  their documentation
- Cherry pick the most recent commit from the releases page, or use the
  `example.patch` checked into this repo as a starting point
- Build the project with something like `./swift/utils/build-script
  --release`
- If you'd like a fat binary for supporting arm64 and x86_64 macs, build
  with `./swift/utils/build-script --release --cross-compile-hosts
  macosx-x86_64`
- Run `create-xcframework.sh binary1 binary2` to create the combined
  framework

## Notes

- This method doesn't actually produce a static binary, but it produces
  a relocatable object file which is similar enough for this use case.
  This is because cmake cannot create distributable static library
  targets that include all of their nested dependencies
- Be sure to pass `-dead_strip` to your linker when linking this library
  with a binary to save on binary size (you likely already are)

[swift-syntax]: https://github.com/apple/swift-syntax
