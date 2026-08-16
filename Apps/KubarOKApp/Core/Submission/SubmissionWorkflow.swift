import Foundation
import KubarOKCore

public struct SubmissionWorkflow: Sendable {
    public private(set) var checks: [SubmissionRequisiteCheck]
    public private(set) var isSubmitting = false
    public private(set) var didSubmit = false
    public private(set) var didFail = false

    public init(checks: [SubmissionRequisiteCheck] = []) {
        self.checks = checks
    }

    public var requiredRequisitesComplete: Bool {
        checks.allSatisfy { check in
            guard check.requisite?.isRequired != 0 else { return true }
            return check.isCompleted != 0
        }
    }

    public mutating func replaceChecks(_ checks: [SubmissionRequisiteCheck]) {
        self.checks = checks
    }

    public mutating func beginFinalSubmit() -> Bool {
        guard !isSubmitting, !didSubmit, requiredRequisitesComplete else { return false }
        isSubmitting = true
        didFail = false
        return true
    }

    public mutating func finishFinalSubmit(success: Bool) {
        isSubmitting = false
        didSubmit = success
        didFail = !success
    }
}
