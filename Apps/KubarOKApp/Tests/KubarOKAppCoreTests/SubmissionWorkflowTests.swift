import Testing
import KubarOKAppCore
import KubarOKCore

@Test func submissionWorkflowStartsWithNoCompletion() {
    let workflow = SubmissionWorkflow(checks: [requiredCheck(completed: 0)])
    #expect(!workflow.requiredRequisitesComplete)
}

@Test func submissionWorkflowRequiresPersistedRequiredChecks() {
    let workflow = SubmissionWorkflow(checks: [requiredCheck(completed: 1), optionalCheck(completed: 0)])
    #expect(workflow.requiredRequisitesComplete)
}

@Test func submissionWorkflowPreventsDoubleFinalSubmit() {
    var workflow = SubmissionWorkflow(checks: [requiredCheck(completed: 1)])
    let firstAttempt = workflow.beginFinalSubmit()
    let secondAttempt = workflow.beginFinalSubmit()
    #expect(firstAttempt)
    #expect(!secondAttempt)
}

@Test func submissionWorkflowTransitionsAfterSuccess() {
    var workflow = SubmissionWorkflow(checks: [requiredCheck(completed: 1)])
    _ = workflow.beginFinalSubmit()
    workflow.finishFinalSubmit(success: true)
    #expect(workflow.didSubmit)
    #expect(!workflow.isSubmitting)
    #expect(!workflow.didFail)
}

@Test func submissionWorkflowTransitionsAfterFailure() {
    var workflow = SubmissionWorkflow(checks: [requiredCheck(completed: 1)])
    _ = workflow.beginFinalSubmit()
    workflow.finishFinalSubmit(success: false)
    #expect(!workflow.didSubmit)
    #expect(workflow.didFail)
}

private func requiredCheck(completed: Int) -> SubmissionRequisiteCheck {
    SubmissionRequisiteCheck(id: 1, isCompleted: completed, submissionId: 10, requisiteId: 2, requisite: ServiceRequisite(id: 2, serviceId: 1, documentTypeId: nil, title: "Wajib", description: nil, isRequired: 1, kind: 0, sequence: 1, externalLink: nil, documents: nil, inputs: nil))
}

private func optionalCheck(completed: Int) -> SubmissionRequisiteCheck {
    SubmissionRequisiteCheck(id: 2, isCompleted: completed, submissionId: 10, requisiteId: 3, requisite: ServiceRequisite(id: 3, serviceId: 1, documentTypeId: nil, title: "Opsional", description: nil, isRequired: 0, kind: 0, sequence: 2, externalLink: nil, documents: nil, inputs: nil))
}
