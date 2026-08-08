//
//  Coder Module Boundary Tests.swift
//  swift-coder-primitives
//
//  Runtime binding for the cross-module SIL-verification control.
//

import Coder_Module_Boundary_Control
import Coder_Primitives
import Testing

extension Coder.Boundary {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension Coder.Boundary.Test.Integration {
    @Test
    func `downstream leaf and closure witness coexist across modules`() {
        Coder.Boundary.exercise()
    }
}
