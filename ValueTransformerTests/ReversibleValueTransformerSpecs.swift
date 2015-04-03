//  Copyright (c) 2015 Felix Jendrusch. All rights reserved.

import Quick
import Nimble

import LlamaKit
import ValueTransformer

struct ReversibleValueTransformers {
    static let string = combine(ValueTransformers.string, ValueTransformers.int)
}

class ReversibleValueTransformerSpecs: QuickSpec {
    override func spec() {
        describe("A (combined) ReversibleValueTransformer") {
            let valueTransformer = ReversibleValueTransformers.string

            it("should transform a value") {
                let result = valueTransformer.transform("1")

                expect(result.value).to(equal(1))
            }

            it("should fail if its value transformation fails") {
                let result = valueTransformer.transform("1.5")

                expect(result.isSuccess).to(beFalse())
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransform(2)

                expect(result.value).to(equal("2"))
            }

            it("should fail if its reverse value transformation fails") {
                let result = flip(valueTransformer).reverseTransform("2.5")

                expect(result.isSuccess).to(beFalse())
            }
        }

        describe("A flipped ReversibleValueTransformer") {
            let valueTransformer = flip(ReversibleValueTransformers.string)

            it("should transform a value") {
                let result = valueTransformer.transform(3)

                expect(result.value).to(equal("3"))
            }

            it("should fail if its value transformation fails") {
                let result = flip(valueTransformer).transform("3.5")

                expect(result.isSuccess).to(beFalse())
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransform("4")
                
                expect(result.value).to(equal(4))
            }

            it("should fail if its reverse value transformation fails") {
                let result = valueTransformer.reverseTransform("4.5")

                expect(result.isSuccess).to(beFalse())
            }
        }

        describe("Composed reversible value transformes") {
            let valueTransformer = ReversibleValueTransformers.string >>> flip(ReversibleValueTransformers.string)

            it("should transform a value") {
                let result = valueTransformer.transform("3")

                expect(result.value).to(equal("3"))
            }

            it("should fail if any of its value transformation fails") {
                let result = valueTransformer.transform("3.5")

                expect(result.isSuccess).to(beFalse())
            }

            it("should reverse transform a value") {
                let result = valueTransformer.reverseTransform("4")

                expect(result.value).to(equal("4"))
            }

            it("should fail if its reverse value transformation fails") {
                let result = valueTransformer.reverseTransform("4.5")

                expect(result.isSuccess).to(beFalse())
            }
        }

        describe("Lifted reversible value transformers") {
            context("with optional value") {
                let valueTransformer: ReversibleValueTransformer<String?, Int, NSError> = lift(ReversibleValueTransformers.string, defaultTransformedValue: 0)

                context("if given some value") {
                    it("should transform a value") {
                        let result = valueTransformer.transform("5")

                        expect(result.value).to(equal(5))
                    }

                    it("should fail if its value transformation fails") {
                        let result = valueTransformer.transform("5.5")

                        expect(result.isSuccess).to(beFalse())
                    }
                }

                context("if not given some value") {
                    it("should transform to the default transformed value") {
                        let result = valueTransformer.transform(nil)

                        expect(result.value).to(equal(0))
                    }
                }

                it("should reverse transform a value") {
                    let result = valueTransformer.reverseTransform(6)

                    expect(result.value?).to(equal("6"))
                }

                it("should fail if its reverse value transformation fails") {
                    let result = flip(valueTransformer).reverseTransform("6.5")

                    expect(result.isSuccess).to(beFalse())
                }
            }

            context("with optional transformed value") {
                let valueTransformer: ReversibleValueTransformer<String, Int?, NSError> = lift(ReversibleValueTransformers.string, defaultReverseTransformedValue: "zero")

                it("should transform a value") {
                    let result = valueTransformer.transform("7")

                    expect(result.value?).to(equal(7))
                }

                it("should fail if its value transformation fails") {
                    let result = valueTransformer.transform("7.5")

                    expect(result.isSuccess).to(beFalse())
                }

                context("if given some transformed value") {
                    it("should reverse transform a value") {
                        let result = valueTransformer.reverseTransform(8)

                        expect(result.value).to(equal("8"))
                    }

                    it("should fail if its value transformation fails") {
                        let result = flip(valueTransformer).reverseTransform("8.5")

                        expect(result.isSuccess).to(beFalse())
                    }
                }

                context("if not given some transformed value") {
                    it("should transform to the default value") {
                        let result = valueTransformer.reverseTransform(nil)

                        expect(result.value).to(equal("zero"))
                    }
                }
            }

            context("with optional value and transformed value") {
                let valueTransformer: ReversibleValueTransformer<String?, Int?, NSError> = lift(ReversibleValueTransformers.string)

                context("if given some value") {
                    it("should transform a value") {
                        let result = valueTransformer.transform("9")

                        expect(result.value?).to(equal(9))
                    }

                    it("should fail if its value transformation fails") {
                        let result = valueTransformer.transform("9.5")

                        expect(result.isSuccess).to(beFalse())
                    }
                }

                context("if not given some value") {
                    it("should transform to nil") {
                        let result = valueTransformer.transform(nil)

                        expect(result.value?).to(beNil())
                    }
                }

                context("if given some transformed value") {
                    it("should reverse transform a value") {
                        let result = valueTransformer.reverseTransform(10)

                        expect(result.value?).to(equal("10"))
                    }

                    it("should fail if its value transformation fails") {
                        let result = flip(valueTransformer).reverseTransform("10.5")

                        expect(result.isSuccess).to(beFalse())
                    }
                }

                context("if not given some transformed value") {
                    it("should transform to nil") {
                        let result = valueTransformer.reverseTransform(nil)

                        expect(result.value?).to(beNil())
                    }
                }
            }

            context("with array value and transformed value") {
                let valueTransformer: ReversibleValueTransformer<[String], [Int], NSError> = lift(ReversibleValueTransformers.string)

                it("should transform a value") {
                    let result = valueTransformer.transform([ "11", "12" ])

                    expect(result.value).to(equal([ 11, 12 ]))
                }

                it("should fail if any of its value transformation fails") {
                    let result = valueTransformer.transform([ "11", "12.5" ])

                    expect(result.isSuccess).to(beFalse())
                }

                it("should reverse transform a value") {
                    let result = valueTransformer.reverseTransform([ 13, 14 ])

                    expect(result.value).to(equal([ "13", "14" ]))
                }

                it("should fail if its reverse value transformation fails") {
                    let result = flip(valueTransformer).reverseTransform([ "13", "14.5" ])
                    
                    expect(result.isSuccess).to(beFalse())
                }
            }

            context("with a dictionary") {
                let valueTransformer: ReversibleValueTransformer<String, Int, NSError> = lift([ "fifteen": 15 ], defaultTransformedValue: 0, defaultReverseTransformedValue: "zero")
                
                it("should transform a value") {
                    let result = valueTransformer.transform("fifteen")
                    
                    expect(result.value).to(equal(15))
                }
                
                it("should succeed with the default transformed value if the value is not mapped") {
                    let result = valueTransformer.transform("sixteen")
                    
                    expect(result.value).to(equal(0))
                }

                it("should reverse transform a value") {
                    let result = valueTransformer.reverseTransform(15)

                    expect(result.value).to(equal("fifteen"))
                }

                it("should succeed with the default reverse transformed value if the transformed value is not mapped") {
                    let result = valueTransformer.reverseTransform(16)

                    expect(result.value).to(equal("zero"))
                }
            }
        }
    }
}
