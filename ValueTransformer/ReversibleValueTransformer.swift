//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public struct ReversibleValueTransformer<Value, TransformedValue, Error: ErrorType>: ReversibleValueTransformerType {
    private let transformClosure: Value -> Result<TransformedValue, Error>
    private let reverseTransformClosure: TransformedValue -> Result<Value, Error>

    public init(transformClosure: Value -> Result<TransformedValue, Error>, reverseTransformClosure: TransformedValue -> Result<Value, Error>) {
        self.transformClosure = transformClosure
        self.reverseTransformClosure = reverseTransformClosure
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return transformClosure(value)
    }

    public func reverseTransform(transformedValue: TransformedValue) -> Result<Value, Error> {
        return reverseTransformClosure(transformedValue)
    }
}

extension ReversibleValueTransformer {
    public init<V: ReversibleValueTransformerType where V.ValueType == Value, V.TransformedValueType == TransformedValue, V.VTErrorType == Error>(_ reversibleValueTransformer: V) {
        self.init(transformClosure: { value in
            return reversibleValueTransformer.transform(value)
        }, reverseTransformClosure: { transformedValue in
            return reversibleValueTransformer.reverseTransform(transformedValue)
        })
    }
}

// MARK: - Combine

public func combine<V: ValueTransformerType, W: ValueTransformerType where V.ValueType == W.TransformedValueType, V.TransformedValueType == W.ValueType, V.VTErrorType == W.VTErrorType>(valueTransformer: V, _ reverseValueTransformer: W) -> ReversibleValueTransformer<V.ValueType, V.TransformedValueType, V.VTErrorType> {
    return ReversibleValueTransformer(transformClosure: transform(valueTransformer), reverseTransformClosure: transform(reverseValueTransformer))
}

// MARK: - Flip

public func flip<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.TransformedValueType, V.ValueType, V.VTErrorType> {
    return ReversibleValueTransformer(transformClosure: reverseTransform(reversibleValueTransformer), reverseTransformClosure: transform(reversibleValueTransformer))
}

// MARK: - Compose

public func compose<V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValueType == W.ValueType, V.VTErrorType == W.VTErrorType>(left: V, _ right: W) -> ReversibleValueTransformer<V.ValueType, W.TransformedValueType, W.VTErrorType> {
    return combine(left >>> right as ValueTransformer, flip(right) >>> flip(left) as ValueTransformer)
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.TransformedValueType == W.ValueType, V.VTErrorType == W.VTErrorType>(lhs: V, rhs: W) -> ReversibleValueTransformer<V.ValueType, W.TransformedValueType, W.VTErrorType> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ReversibleValueTransformerType, W: ReversibleValueTransformerType where V.ValueType == W.TransformedValueType, V.VTErrorType == W.VTErrorType>(lhs: V, rhs: W) -> ReversibleValueTransformer<W.ValueType, V.TransformedValueType, V.VTErrorType> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultReverseTransformedValue: V.ValueType) -> ReversibleValueTransformer<V.ValueType, V.TransformedValueType?, V.VTErrorType> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer), defaultTransformedValue: defaultReverseTransformedValue) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, defaultTransformedValue: V.TransformedValueType) -> ReversibleValueTransformer<V.ValueType?, V.TransformedValueType, V.VTErrorType> {
    return combine(lift(reversibleValueTransformer, defaultTransformedValue: defaultTransformedValue) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<V.ValueType?, V.TransformedValueType?, V.VTErrorType> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}

// MARK: - Lift (Array)

public func lift<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> ReversibleValueTransformer<[V.ValueType], [V.TransformedValueType], V.VTErrorType> {
    return combine(lift(reversibleValueTransformer) as ValueTransformer, lift(flip(reversibleValueTransformer)) as ValueTransformer)
}
