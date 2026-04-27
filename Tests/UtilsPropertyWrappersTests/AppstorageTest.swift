//
//  File.swift
//
//
//  Created by Home on 04/04/26.
//
#if canImport(Darwin)
import XCTest

final class AppStorageTests: XCTestCase {
    private func strings(int: Int) -> [String] { [
        "the int obj \(int)",
        "the int obj Binding: \(int)",
        "the int: \(int)",
        "the int Binding: \(int)"
    ]}
    
    @MainActor func testView() throws {
        MyViewWithFourSteppers().testSetup { view in
            UserDefaults.standard.set(0, forKey: "intKey")
            var int = 0
            let steperCount = 4
            let indices = 0..<steperCount
            
            XCTAssertEqual(view.steppers.count, steperCount)
            for i in indices {
                try view.steppers[i].increment()
                int += 1
                
                for (string, stepper) in zip(self.strings(int: int), view.steppers) {
                    XCTAssertEqual(try stepper.labelView().text().string(), string)
                }
            }
            // this should not fail the test
            // UserDefaults.standard.setValue(50, forKey: "intKey")
            
            for i in indices {
                try view.steppers[i].decrement()
                int -= 1
                
                for (string, stepper) in zip(self.strings(int: int), view.steppers) {
                    XCTAssertEqual(try stepper.labelView().text().string(), string)
                }
            }
        }
    }
}
#endif
