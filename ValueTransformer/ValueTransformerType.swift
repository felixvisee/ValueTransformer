//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit

public protocol ValueTransformerType {
    typealias ValueType
    typealias TransformedValueType
    typealias ErrorType

    func transform(value: ValueType) -> Result<TransformedValueType, ErrorType>
}

// MARK: - Basics

public func transform<V: ValueTransformerType>(valueTransformer: V, value: V.ValueType) -> Result<V.TransformedValueType, V.ErrorType> {
    return valueTransformer.transform(value)
}

public func transform<V: ValueTransformerType>(valueTransformer: V)(value: V.ValueType) -> Result<V.TransformedValueType, V.ErrorType> {
    return valueTransformer.transform(value)
}
