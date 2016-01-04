//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public struct ValueTransformer<Value, TransformedValue, Error: ErrorType>: ValueTransformerType {
    private let transformClosure: Value -> Result<TransformedValue, Error>

    public init(transformClosure: Value -> Result<TransformedValue, Error>) {
        self.transformClosure = transformClosure
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return transformClosure(value)
    }
}

extension ValueTransformer {
    public init<V: ValueTransformerType where V.ValueType == Value, V.TransformedValueType == TransformedValue, V.VTErrorType == Error>(_ valueTransformer: V) {
        self.init(transformClosure: { value in
            return valueTransformer.transform(value)
        })
    }
}

// MARK: - Compose

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.VTErrorType == W.VTErrorType>(left: V, _ right: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.VTErrorType> {
    return ValueTransformer { value in
        return left.transform(value).flatMap(transform(right))
    }
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.VTErrorType == W.VTErrorType>(lhs: V, rhs: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.VTErrorType> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.ValueType == W.TransformedValueType, V.VTErrorType == W.VTErrorType>(lhs: V, rhs: W) -> ValueTransformer<W.ValueType, V.TransformedValueType, V.VTErrorType> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType, V.TransformedValueType?, V.VTErrorType> {
    return ValueTransformer { value in
        return valueTransformer.transform(value).map { value in
            return .Some(value)
        }
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V, defaultTransformedValue: V.TransformedValueType) -> ValueTransformer<V.ValueType?, V.TransformedValueType, V.VTErrorType> {
    let closure: V.ValueType? -> Result<V.TransformedValueType, V.VTErrorType> = {
        value in
        return value.map(transform(valueTransformer)) ?? Result.Success(defaultTransformedValue)
    }

    return ValueTransformer(transformClosure: closure)
}

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType?, V.TransformedValueType?, V.VTErrorType> {
    return lift(lift(valueTransformer), defaultTransformedValue: nil)
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.ValueType], [V.TransformedValueType], V.VTErrorType> {
    let closure: [V.ValueType] -> Result<[V.TransformedValueType], V.VTErrorType> = {
        values in
        return values.reduce(Result.Success([])) { (result, value) in
            return result.flatMap { result in
                return valueTransformer.transform(value).map { value in
                    return result + [ value ]
                }
            }
        }
    }

    return ValueTransformer(transformClosure: closure)
}
