//
//  File.swift
//  
//
//  Created by Home on 27/04/26.
//

#if canImport(Darwin)
import SwiftUI
import ViewInspector

protocol TestView: View {
    var inspection: Inspection<Self> {get}
}

extension TestView {
    typealias ViewInspection = @MainActor @Sendable (InspectableView<ViewType.View<Self>>) async throws -> Void
    
    @MainActor func testSetup(_ inspection: @escaping ViewInspection) {
        ViewHosting.host(view: self)
        
        let expectation = self.inspection.inspect(inspection)
        ViewTestHelper.waitFor(expectation)
        ViewHosting.host(view: EmptyView())
    }
}

extension InspectableView {
    var steppers: [InspectableView<ViewType.Stepper>] {
        findAll(ViewType.Stepper.self)
    }
}
#endif
