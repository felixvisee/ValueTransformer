//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import LlamaKit

internal func pure<T>(x: T) -> T? {
    return .Some(x)
}

internal func reverse<Key: Hashable, Value: Hashable>(dictionary: [Key: Value]) -> [Value: Key] {
    var result: [Value: Key] = [:]
    for (key, value) in dictionary {
        result[value] = key
    }

    return result
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
