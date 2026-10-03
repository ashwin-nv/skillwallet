[README.md](https://github.com/user-attachments/files/32899560/README.md)
# Support Ticket Intelligence: Phase 2 Starter

This is a Salesforce DX source scaffold for the SkillWallet Phase 2 backend. It includes the custom object and fields, an invocable deterministic classifier, and Apex tests. It has **not** been deployed to a Salesforce org. The record-triggered Flow, user/queue assignment policy, tab/app, field permissions, and Agentforce topic are org-specific setup steps below.

## 1. Requirements

- A Salesforce Developer org with API access. Agentforce features vary by org edition and entitlements; use the Apex rules below as the first-pass fallback if Agentforce is unavailable.
- Salesforce CLI (`sf`) installed on the computer where you will deploy.
- A team-approved assignment policy and support users. Do not hard-code a teammate as the permanent owner.

## 2. Log in and deploy the source

Open a terminal in this folder (`salesforce-project/`). Log in through the Salesforce browser page, then deploy the object, fields, trigger, and Apex classes:

```sh
sf --version
sf org login web --instance-url https://login.salesforce.com --alias ticket-dev --set-default
sf org display --target-org ticket-dev
sf project deploy start --source-dir force-app --target-org ticket-dev --wait 20
```

The login command opens Salesforce for you to sign in. It does not create a Developer org. Create/activate the org first if you do not already have one. For a sandbox, use `https://test.salesforce.com` as the instance URL and choose an appropriate alias.

## 3. Confirm the object and fields

The deployment creates `Support_Ticket_Intelligence__c` with an auto-number name (`TKT-00001`) and private sharing by default. Fields include Description, Issue Type, Priority, Status, Account, Contact, Assigned Agent, SLA Breach Risk, Resolution Time Minutes, and Classification Reason.

Open the org and review the result:

```sh
sf org open --target-org ticket-dev
```

In Setup, open **Object Manager → Support Ticket Intelligence → Fields & Relationships**. Check the field types and values before moving on.

## 4. Add a tab and app navigation

Follow the project milestone in Setup:

1. Open **Setup → Tabs → Custom Object Tabs → New**.
2. Choose **Support Ticket Intelligence**, select a tab style, and continue.
3. Keep the intended profiles enabled; add the tab to the support app navigation.
4. Save, then confirm the tab appears in the app for an agent test user.

## 5. Add the record-triggered Flow

Create a **Record-Triggered Flow** on `Support_Ticket_Intelligence__c`:

1. Trigger after save when a record is created or updated and `Description__c` is not blank. Choose the setting that runs updates only when the record newly meets the entry conditions, so writing the priority does not create a loop.
2. Add the Apex Action **Classify Support Ticket**. Map the record's `Description__c` to **Ticket Description**.
3. Add **Update Records** for the triggering ticket. Set `Priority__c` from the action's Priority output and `Classification_Reason__c` from its reason output.
4. Add a Decision for High priority. On the High path, create a Salesforce Task linked to the ticket (`WhatId` = ticket record ID), with a clear subject, owner, due date, and `Not Started` status.
5. On other paths, keep the ticket assigned to the approved support owner. Define the team's assignment rule (queue, issue type, skill, or workload) with the project team before enabling it. `Assigned_Agent__c` is a User lookup; it must receive a real active User ID.
6. Save as `Support Ticket Triage`, run Flow Debug against sample records, then activate after tests pass.

The Apex action is intentionally deterministic: High for outage/security/access-critical signals, Medium for service degradation/urgency indicators, Low otherwise. It is a safe baseline, not an AI prediction model.

## 6. Apply access controls

Keep the object's default sharing **Private**. In Setup, create agent and manager permission sets. Grant agents create/read and only approved updates; remove edit access to Priority, SLA Breach Risk, and Classification Reason. Grant managers team-wide visibility and override access. Configure sharing/role hierarchy so agents see tickets assigned to them and managers can review the team. Verify with separate agent and manager test users.

## 7. Configure Agentforce (if enabled in the org)

In Agentforce Builder, create a **Support Ticket Priority Analysis** topic and an action that supplies only the ticket description. Instruct the agent to return High/Medium/Low, a short reason, and an uncertainty indicator. Tell it not to infer missing facts or make commitments; ambiguous cases should go to a human. Connect the action in the Flow only after confirming the org exposes the required Agentforce action. Keep a deterministic Flow fallback and human override.

## 8. Run tests and verify

```sh
sf apex run test --class-names TicketTriageActionTest,SupportTicketValidationTest --target-org ticket-dev --code-coverage --result-format human --wait 10
sf org open --target-org ticket-dev
```

Check the Apex test results and coverage. In the org, test at least these records: outage/security issue (High), degraded/slow service (Medium), routine request (Low), missing Account, blank Description, and an agent attempting to edit a protected field. Debug the Flow, review records/tasks, and only then mark the SkillWallet tasks complete.

## 9. Publish the team links

After a successful deployment and review, create a GitHub repository for this folder and add the repository URL plus the actual demo video URL to the project. The walkthrough video in the outputs folder is instructional; it is not evidence of a completed Salesforce deployment.

## Source files

- `force-app/main/default/objects/Support_Ticket_Intelligence__c/`: object and custom fields.
- `force-app/main/default/classes/`: invocable classifier and unit tests.
- `force-app/main/default/triggers/`: required Account and Description checks and tests.
