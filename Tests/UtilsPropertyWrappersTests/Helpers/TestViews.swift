//
//  File.swift
//  
//
//  Created by Home on 27/04/26.
//
#if canImport(Darwin)
import SwiftUI
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

struct TestViewDirect: View {
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

struct MyViewWithFourSteppers: TestView {
    let inspection = Inspection<Self>()
    
    //TODO: - test with conflicting default Values
    var body: some View {
        VStack {
            TestViewObj()
            TestViewObjBinding()
            TestViewDirect()
            TestViewBinding()
        }
        .onReceive(inspection.notice) { x in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.inspection.visit(self, x)
            }
        }
    }
}
#endif
