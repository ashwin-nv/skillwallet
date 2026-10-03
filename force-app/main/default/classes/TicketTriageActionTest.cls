@IsTest
private class TicketTriageActionTest {
    @IsTest
    static void classifiesCriticalSignalsAsHigh() {
        TicketTriageAction.Request request = new TicketTriageAction.Request();
        request.description = 'Production service outage: all customers cannot access the portal';

        List<TicketTriageAction.Outcome> results = TicketTriageAction.classify(
            new List<TicketTriageAction.Request>{request}
        );

        System.assertEquals('High', results[0].priority);
        System.assert(results[0].reason.contains('Critical'));
    }

    @IsTest
    static void classifiesRoutineIssuesAsLowAndServiceIssuesAsMedium() {
        TicketTriageAction.Request routine = new TicketTriageAction.Request();
        routine.description = 'Please explain how to update my contact preferences';
        TicketTriageAction.Request serviceIssue = new TicketTriageAction.Request();
        serviceIssue.description = 'The page is slow and not working';

        List<TicketTriageAction.Outcome> results = TicketTriageAction.classify(
            new List<TicketTriageAction.Request>{routine, serviceIssue}
        );

        System.assertEquals('Low', results[0].priority);
        System.assertEquals('Medium', results[1].priority);
    }

    @IsTest
    static void handlesBlankDescriptionSafely() {
        TicketTriageAction.Request request = new TicketTriageAction.Request();
        List<TicketTriageAction.Outcome> results = TicketTriageAction.classify(
            new List<TicketTriageAction.Request>{request}
        );
        System.assertEquals('Low', results[0].priority);
        System.assertNotEquals(null, results[0].reason);
    }
}
