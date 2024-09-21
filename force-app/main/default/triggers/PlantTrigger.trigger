trigger PlantTrigger on CAMPX__Plant__c (before insert) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            PlantTriggerHandler.setDefaultValues(Trigger.new);
        }
    }

}