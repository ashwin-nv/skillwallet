public with sharing class TicketTriageAction {
    public class Request {
        @InvocableVariable(label='Ticket Description' required=true)
        public String description;
    }

    public class Outcome {
        @InvocableVariable(label='Priority')
        public String priority;

        @InvocableVariable(label='Classification Reason')
        public String reason;
    }

    @InvocableMethod(label='Classify Support Ticket' description='Apply baseline urgency rules to a ticket description.')
    public static List<Outcome> classify(List<Request> requests) {
        List<Outcome> results = new List<Outcome>();
        for (Request request : requests) {
            String text = request == null || request.description == null
                ? ''
                : request.description.toLowerCase();
            Outcome result = new Outcome();

            if (containsAny(text, new List<String>{'outage', 'service down', 'data breach', 'security incident', 'cannot access'})) {
                result.priority = 'High';
                result.reason = 'Critical outage, access, or security signal detected.';
            } else if (containsAny(text, new List<String>{'urgent', 'not working', 'slow', 'degraded', 'blocked'})) {
                result.priority = 'Medium';
                result.reason = 'Service issue or urgency signal detected; agent should confirm impact.';
            } else {
                result.priority = 'Low';
                result.reason = 'No high-impact signal detected; review and adjust if needed.';
            }
            results.add(result);
        }
        return results;
    }

    private static Boolean containsAny(String text, List<String> terms) {
        for (String term : terms) {
            if (text.contains(term)) return true;
        }
        return false;
    }
}
