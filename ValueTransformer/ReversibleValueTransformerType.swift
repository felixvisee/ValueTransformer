//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

public protocol ReversibleValueTransformerType: ValueTransformerType {
    func reverseTransform(transformedValue: TransformedValueType) -> Result<ValueType, ErrorType>
}

// MARK: - Basics

public func reverseTransform<V: ReversibleValueTransformerType>(reversibleValueTransformer: V, transformedValue: V.TransformedValueType) -> Result<V.ValueType, V.ErrorType> {
    return reversibleValueTransformer.reverseTransform(transformedValue)
}
