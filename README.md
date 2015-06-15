# ValueTransformer

Type-safe value transformers with error handling, inspired by [Mantle 2.0's](https://github.com/mantle/mantle/tree/2.0-development) [MTLTransformerErrorHandling](https://github.com/Mantle/Mantle/blob/2.0-development/Mantle/MTLTransformerErrorHandling.h).

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

1. Add ValueTransformer to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

  ```
  github "felixjendrusch/ValueTransformer" ~> 2.3
  ```

2. Run `carthage update` to fetch and build ValueTransformer and its dependencies.

3. [Make sure your application's target links against `ValueTransformer.framework` and copies all relevant frameworks into its application bundle (iOS); or embeds the binaries of all relevant frameworks (Mac).](https://github.com/carthage/carthage#getting-started)

## Usage

### `ValueTransformer`

A `ValueTransformer` supports closure-based forward value transformation. It conforms to `ValueTransformerType`.

```swift
let uppercase = ValueTransformer<String, String, NSError> { value in
  return success(value.uppercaseString)
}

let result = uppercase.transform("example") // "EXAMPLE"
```

#### `>>>` and `<<<`

Value transformers can be chained together using the left-to-right and right-to-left composition operators (`>>>` and `<<<` respectively):

```swift
let join = ValueTransformer<[String], String, NSError> { values in
  return success(" ".join(values))
}

let result = (join >>> uppercase).transform([ "hello", "world" ]) // "HELLO WORLD"
```

#### `lift` (Optional)

The value and transformed value type of a value transformer can be lifted into an `Optional`:

```swift
let lifted: ValueTransformer<String, String?, NSError> = lift(uppercase)

let result = lifted.transform("example") // .Some("EXAMPLE")
```

```swift
let lifted: ValueTransformer<String?, String, NSError> = lift(uppercase, defaultTransformedValue: "default")

let result1 = lifted.transform("example") // "EXAMPLE"
let result2 = lifted.transform(nil) // "default"
```

```swift
let lifted: ValueTransformer<String?, String?, NSError> = lift(uppercase)

let result = lifted.transform(nil) // nil
```

#### `lift` (Array)

The value and transformed value type of a value transformer can also be lifted into an `Array`:

```swift
let lifted: ValueTransformer<[String], [String], NSError> = lift(uppercase)

let result = lifted.transform([ "hello", "world" ]) // [ "HELLO", "WORLD" ]
```

### `ReversibleValueTransformer`

A `ReversibleValueTransformer` supports closure-based forward and backward value transformation. It conforms to `ReversibleValueTransformerType`, which in turn conforms to `ValueTransformerType`.

```swift
let caze = ReversibleValueTransformer<String, String, NSError>(transformClosure: { value in
  return success(value.uppercaseString)
}, reverseTransformClosure: { transformedValue in
  return success(transformedValue.lowercaseString)
})

let result1 = caze.transform("example") // "EXAMPLE"
let result2 = caze.reverseTransform("EXAMPLE") // "example"
```

The same operations that can be applied to a `ValueTransformer` may also be applied to a `ReverisbleValueTransformer`. In addition, the following operations are supported.

#### `combine`

Two suitable value transformers can be combined into a reversible value transformer:

```swift
let lowercase = ValueTransformer<String, String, NSError> { value in
  return success(value.lowercaseString)
}

let combined = combine(uppercase, lowercase)

let result1 = combined.transform("example") // "EXAMPLE"
let result2 = combined.reverseTransform("EXAMPLE") // "example"
```

#### `flip`

A reversible value transformer can be flipped:

```swift
let flipped = flip(combined)

let result1 = flipped.transform("EXAMPLE") // "example"
let result2 = flipped.reverseTransform("example") // "EXAMPLE"
```

#### `lift` (Optional)

When lifting the transformed value type of a reversible value transformer into an `Optional`, a default reverse transformed value must be provided:

```swift
let lifted = lift(flipped, defaultReverseTransformedValue: "default")

let result1 = lifted.reverseTransform("example") // "EXAMPLE"
let result2 = lifted.reverseTransform(nil) // "default"
```

## Error handling

All transformations and reverse transformations return a [`Result`](https://github.com/antitypical/Result/blob/master/Result/Result.swift), which either holds the (reverse) transformed value or an error. This enables you to gracefully handle transformation errors.
