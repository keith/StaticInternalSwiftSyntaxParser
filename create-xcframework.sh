#!/bin/bash

set -euo pipefail
set -x

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 path/to/swift/checkout path/to/arm64 path/to/x86_64"
  exit 1
fi

include_dir=$1/swift/include/swift-c/SyntaxParser
shift
if [[ "$include_dir" != /* ]]; then
  include_dir="$PWD/$include_dir"
fi

if [[ ! -d "$include_dir" ]]; then
  echo "error: failed to find syntax parser include directory, please file an issue" >&2
  exit 1
fi

if [[ "$1" == /* ]]; then
  binary1="$1"
else
  binary1="$PWD/$1"
fi

if [[ "$2" == /* ]]; then
  binary2="$2"
else
  binary2="$PWD/$2"
fi

workdir=$(mktemp -d)
pushd "$workdir"
mkdir -p lib_InternalSwiftSyntaxParser.framework/Headers lib_InternalSwiftSyntaxParser.framework/Modules
cp "$include_dir"/*.h lib_InternalSwiftSyntaxParser.framework/Headers

echo 'framework module _InternalSwiftSyntaxParser {
  umbrella header "SwiftSyntaxParser.h"
  export *
  module * { export * }
}' > lib_InternalSwiftSyntaxParser.framework/Modules/module.modulemap
lipo -create -output lib_InternalSwiftSyntaxParser.framework/lib_InternalSwiftSyntaxParser "$binary1" "$binary2"
xcodebuild -create-xcframework -framework lib_InternalSwiftSyntaxParser.framework -output lib_InternalSwiftSyntaxParser.xcframework
popd
rm -rf ./lib_InternalSwiftSyntaxParser.xcframework ./lib_InternalSwiftSyntaxParser.xcframework.zip
mv "$workdir/lib_InternalSwiftSyntaxParser.xcframework" .
zip -r lib_InternalSwiftSyntaxParser.xcframework.zip lib_InternalSwiftSyntaxParser.xcframework
