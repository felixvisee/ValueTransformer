//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit

internal func unit<T>(x: T) -> T? {
    return .Some(x)
}

internal func map<S: SequenceType, T, E>(sequence: S, transform: (S.Generator.Element) -> Result<T, E>) -> Result<[T], E> {
    var result: [T] = []
    for element in sequence {
        switch transform(element) {
        case .Success(let value):
            result.append(value.unbox)
        case .Failure(let error):
            return failure(error.unbox)
        }
    }

    return success(result)
}
