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
