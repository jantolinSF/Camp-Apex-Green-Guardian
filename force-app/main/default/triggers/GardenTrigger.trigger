trigger GardenTrigger on CAMPX__Garden__c (before insert, after insert, before update, after update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            GardenTriggerHandler.setDefaultValues(Trigger.new);
        }

        when AFTER_INSERT {
            GardenTriggerHandler.createManagerTask(Trigger.new);
        }

        when BEFORE_UPDATE {
            GardenTriggerHandler.setManagerStartDate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_UPDATE {
            GardenTriggerHandler.createManagerTaskonUpdate(Trigger.new, Trigger.oldMap);
            GardenTriggerHandler.reassignTaskOwnerorDeleteOnUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}