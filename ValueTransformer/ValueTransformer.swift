//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Prelude
import Result

public struct ValueTransformer<Value, TransformedValue, Error>: ValueTransformerType {
    private let transformClosure: Value -> Result<TransformedValue, Error>

    public init(transformClosure: Value -> Result<TransformedValue, Error>) {
        self.transformClosure = transformClosure
    }

    public func transform(value: Value) -> Result<TransformedValue, Error> {
        return transformClosure(value)
    }
}

// MARK: - Compose

public func compose<V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.ErrorType == W.ErrorType>(left: V, right: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.ErrorType> {
    return ValueTransformer { value in
        return left.transform(value).flatMap(curry(transform)(right))
    }
}

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <V: ValueTransformerType, W: ValueTransformerType where V.TransformedValueType == W.ValueType, V.ErrorType == W.ErrorType>(lhs: V, rhs: W) -> ValueTransformer<V.ValueType, W.TransformedValueType, W.ErrorType> {
    return compose(lhs, rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <V: ValueTransformerType, W: ValueTransformerType where V.ValueType == W.TransformedValueType, V.ErrorType == W.ErrorType>(lhs: V, rhs: W) -> ValueTransformer<W.ValueType, V.TransformedValueType, V.ErrorType> {
    return compose(rhs, lhs)
}

// MARK: - Lift (Optional)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType, V.TransformedValueType?, V.ErrorType> {
    return ValueTransformer { value in
        return valueTransformer.transform(value).map(unit)
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V, #defaultTransformedValue: V.TransformedValueType) -> ValueTransformer<V.ValueType?, V.TransformedValueType, V.ErrorType> {
    return ValueTransformer { value in
        return map(value, curry(transform)(valueTransformer)) ?? Result.success(defaultTransformedValue)
    }
}

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<V.ValueType?, V.TransformedValueType?, V.ErrorType> {
    return lift(lift(valueTransformer), defaultTransformedValue: nil)
}

// MARK: - Lift (Array)

public func lift<V: ValueTransformerType>(valueTransformer: V) -> ValueTransformer<[V.ValueType], [V.TransformedValueType], V.ErrorType> {
    return ValueTransformer { values in
        return reduce(values, Result.success([])) { (result, value) in
            return result.flatMap { result in
                return valueTransformer.transform(value).map { value in
                    return result + [ value ]
                }
            }
        }
    }
}
