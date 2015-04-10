//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Result

internal func unit<T>(x: T) -> T? {
    return .Some(x)
}

internal func map<S: SequenceType, T, E>(sequence: S, transform: (S.Generator.Element) -> Result<T, E>) -> Result<[T], E> {
    var result: Result<[T], E> = Result.success([])
    for element in sequence {
        result = result.flatMap { result in
            return transform(element).map { value in
                return result + [ value ]
            }
        }
    }

    return result
}
