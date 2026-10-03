@IsTest
private class SupportTicketValidationTest {
    @IsTest
    static void requiresCustomerAndDescription() {
        Account account = new Account(Name = 'Validation Test Account');
        insert account;

        Support_Ticket_Intelligence__c missingDescription = new Support_Ticket_Intelligence__c(
            Account__c = account.Id
        );
        try {
            insert missingDescription;
            System.assert(false, 'A blank description should be rejected.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains('Enter a ticket description.'));
        }

        Support_Ticket_Intelligence__c missingAccount = new Support_Ticket_Intelligence__c(
            Description__c = 'The portal is unavailable.'
        );
        try {
            insert missingAccount;
            System.assert(false, 'A missing customer should be rejected.');
        } catch (DmlException error) {
            System.assert(error.getMessage().contains('Choose a customer account.'));
        }
    }
}
