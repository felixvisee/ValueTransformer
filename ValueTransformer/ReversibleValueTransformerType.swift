//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public protocol ReversibleValueTransformerType: ValueTransformerType {
    func reverseTransform(transformedValue: TransformedValueType) -> Result<ValueType, ErrorType>
}

// MARK: - Basics

@available(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.reverseTransform(transformedValue).")
public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, transformedValue: V.TransformedValueType) -> Result<V.ValueType, V.ErrorType> {
    return reversibleValueTransformer.reverseTransform(transformedValue)
}

public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V) -> V.TransformedValueType -> Result<V.ValueType, V.ErrorType> {
    return { transformedValue in
        return reversibleValueTransformer.reverseTransform(transformedValue)
    }
}
