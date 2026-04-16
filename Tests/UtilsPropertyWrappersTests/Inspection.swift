//
//  Inspection.swift
//  UtilsPropertyWrappers
//
//  Created by macm4 on 16/04/26.
//

#if canImport(Darwin)
import XCTest
import ViewInspector
@preconcurrency import Combine

internal final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks: [UInt: (V) -> Void] = [:]
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
extension Inspection: InspectionEmissary { }

struct ViewTestHelper {
    static func waitFor(_ expectation: XCTestExpectation, timeout: TimeInterval = 5.0) {
        XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
}
#endif
