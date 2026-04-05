//
//  File.swift
//  
//
//  Created by Home on 04/04/26.
//

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

struct TestView1: View {
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

struct TestView2: View {
    @AppStorageCodable("intKey") var int = 0
    var body: some View {
        Stepper("the int Binding: \(int)", value: $int)
    }
}

#Preview {
    VStack {
        TestViewObj()
        TestViewObjBinding()
        Divider()
        TestView1()
        TestView2()
    }
    .padding(.horizontal)
}
