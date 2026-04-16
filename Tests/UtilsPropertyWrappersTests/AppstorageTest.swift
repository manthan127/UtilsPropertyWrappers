//
//  File.swift
//  
//
//  Created by Home on 04/04/26.
//
#if canImport(Darwin)
import XCTest
import SwiftUI
import ViewInspector
import UtilsPropertyWrappers

class TestObservableObject: ObservableObject {
    @AppStorageCodablePublished("intKey") var int = 0
}

struct TestViewObj: View {
    @StateObject var obj = TestObservableObject()
    var body: some View {
        Stepper {
            Text("the int obj \(obj.int)")
        } onIncrement: {
            obj.int += 1
        } onDecrement: {
            obj.int -= 1
        }
    }
}

struct TestViewObjBinding: View {
    @StateObject var obj = TestObservableObject()
    var body: some View {
        Stepper("the int obj Binding: \(obj.int)", value: $obj.int)
    }
}

//@Observable
//class TestObservable {
//    @AppStorageCodable("intKey")
//    var int: Int = 0
//}
//
//struct TestViewObservable: View {
//    @State var obj = TestObservable()
//    var body: some View {
//        Stepper {
//            Text("the int obj \(obj.int)")
//        } onIncrement: {
//            obj.int += 1
//        } onDecrement: {
//            obj.int -= 1
//        }
//    }
//}
//
//struct TestViewObservableBinding: View {
//    @State var obj = TestObservable()
//    var body: some View {
//        Stepper("the int obj Binding: \(obj.int)", value: $obj.int)
//    }
//}

struct TestView: View {
    @AppStorageCodable("intKey") var int = 0
    var body: some View {
        Stepper {
            Text("the int: \(int)")
        } onIncrement: {
            int += 1
        } onDecrement: {
            int -= 1
        }
    }
}

struct TestViewBinding: View {
    @AppStorageCodable("intKey") var int = 0
    var body: some View {
        Stepper("the int Binding: \(int)", value: $int)
    }
}

struct MyViewWithFourSteppers: View {
    let inspection = Inspection<Self>()
    
    //TODO: - test with conflicting default Values
    var body: some View {
        VStack {
            TestViewObj()
            TestViewObjBinding()
            TestView()
            TestViewBinding()
        }
        .onReceive(inspection.notice) { x in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.inspection.visit(self, x)
            }
        }
    }
}

final class AppStorageTests: XCTestCase {
    private func strings(int: Int) -> [String] { [
        "the int obj \(int)",
        "the int obj Binding: \(int)",
        "the int: \(int)",
        "the int Binding: \(int)"
    ]}
    
    @MainActor func testView() throws {
        UserDefaults.standard.set(0, forKey: "intKey")
        
        let view = MyViewWithFourSteppers()
        ViewHosting.host(view: view)
        defer { ViewHosting.host(view: EmptyView()) }
        
        var int = 0
        
        let expectation = view.inspection.inspect { sut in
            var steppers: [InspectableView<ViewType.Stepper>] {
                sut.findAll(ViewType.Stepper.self)
            }
            XCTAssertEqual(steppers.count, 4)
            
            for i in steppers.indices {
                try steppers[i].increment()
                int += 1

                for (string, stepper) in zip(self.strings(int: int), steppers) {
                    XCTAssertEqual(try stepper.labelView().text().string(), string)
                }
            }
            // this should not fail the test
            // UserDefaults.standard.setValue(50, forKey: "intKey")
            
            for i in steppers.indices {
                try steppers[i].decrement()
                int -= 1
                
                for (string, stepper) in zip(self.strings(int: int), steppers) {
                    XCTAssertEqual(try stepper.labelView().text().string(), string)
                }
            }
        }
        ViewTestHelper.waitFor(expectation)
    }
}

#Preview {
    MyViewWithFourSteppers()
}
#endif
