trigger SupportTicketValidation on Support_Ticket_Intelligence__c (before insert, before update) {
    for (Support_Ticket_Intelligence__c ticket : Trigger.new) {
        if (ticket.Account__c == null) {
            ticket.Account__c.addError('Choose a customer account.');
        }
        if (String.isBlank(ticket.Description__c)) {
            ticket.Description__c.addError('Enter a ticket description.');
        }
    }
}
