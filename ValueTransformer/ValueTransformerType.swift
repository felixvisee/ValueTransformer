//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public protocol ValueTransformerType {
    typealias ValueType
    typealias TransformedValueType
    typealias VTErrorType: ErrorType

    func transform(value: ValueType) -> Result<TransformedValueType, VTErrorType>
}

// MARK: - Basics

@available(*, introduced=1.0, deprecated=2.1, message="Use valueTransformer.transform(value).")
public func transform<V: ValueTransformerType>(valueTransformer: V, value: V.ValueType) -> Result<V.TransformedValueType, V.VTErrorType> {
    return valueTransformer.transform(value)
}

public func transform<V: ValueTransformerType>(valueTransformer: V) -> V.ValueType -> Result<V.TransformedValueType, V.VTErrorType> {
    return { value in
        valueTransformer.transform(value)
    }
}
