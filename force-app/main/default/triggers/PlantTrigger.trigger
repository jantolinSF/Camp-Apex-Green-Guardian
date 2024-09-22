trigger PlantTrigger on CAMPX__Plant__c (before insert, after insert, after update, after delete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            PlantTriggerHandler.setDefaultValues(Trigger.new);
        }

        when AFTER_INSERT {
            PlantTriggerHandler.calculateTotalPlantCountOnInsertOrDelete(Trigger.new);
        }

        when AFTER_UPDATE {
            PlantTriggerHandler.calculateTotalPlantCountOnUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_DELETE{
            PlantTriggerHandler.calculateTotalPlantCountOnInsertOrDelete(Trigger.old);
        }
    }

}