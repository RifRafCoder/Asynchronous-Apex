/*
 * NextStepQueueable Class Description:
 * 
 * The NextStepQueueable class showcases the usage of the Queueable interface in Salesforce to perform asynchronous operations.
 * 
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */
public with sharing class NextStepQueueable implements Queueable{

    // Member variable to store the accounts
    private Map<Id,Account> accounts;

    // Constructor to accept the accounts
    public NextStepQueueable(Map<Id,Account> accounts) {
        // Store the accounts in a member variable
        this.accounts = accounts;

    }

    // Method to queue the job
    public static void enqueueJob() {
        // Get 10 accounts with Next Step populated
        Map<Id, Account> nextStepAcc = new Map<Id,Account>([SELECT Id, Name, Next_Step__c FROM Account WHERE Next_Step__c !=null LIMIT 10]);
        // If there are any accounts, queue the job using System.enqueueJob
        If(!nextStepAcc.isEmpty()){
            System.enqueueJob(new NextStepQueueable(nextStepAcc));
        }
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */
    public void execute(QueueableContext context) {
        // Get the accounts from the member variable
        Map<Id,Account> accMap = accounts;
            // Remove the Next Step using the helper method
        for(Account acc : accMap.values()){
            removeDescription(acc);
        }
        // Update the accounts
        update accMap.values();
        // Get the opportunities related to the accounts
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Name, AccountId, NextStep FROM Opportunity WHERE AccountId IN :accMap.keySet()]);
            // Remove the Next Step using the helper method
        for(Opportunity opp: oppMap.values()){
            removeDescription(opp);
        }
        // Update the opportunities
        update oppMap.values();
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an opportunity
    private static void removeDescription(Opportunity opp) {
        opp.NextStep = null;
    }

    // Helper method to remove the Next Step
    // Overloaded method to accept an account
    private static void removeDescription(Account acc) {
        acc.Next_Step__c = null;
    }
}