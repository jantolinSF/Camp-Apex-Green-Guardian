public with sharing class GardenTriggerHandler {

    final static String DEFAULT_TASK_SUBJECT = 'Acquire Plants';
    
    
    public static void setDefaultValues( List<CAMPX__Garden__c> newGardens ) {

        final String DEFAULT_STATUS = 'Awaiting Resources';

        for ( CAMPX__Garden__c garden : newGardens ) {
            
            garden.CAMPX__Status__c = garden.CAMPX__Status__c == null ? garden.CAMPX__Status__c : DEFAULT_STATUS;
            garden.CAMPX__Max_Plant_Count__c = garden.CAMPX__Max_Plant_Count__c != null ? garden.CAMPX__Max_Plant_Count__c : 100;
            garden.CAMPX__Minimum_Plant_Count__c = garden.CAMPX__Minimum_Plant_Count__c != null ? garden.CAMPX__Minimum_Plant_Count__c : 1;
            garden.CAMPX__Total_Plant_Count__c = garden.CAMPX__Total_Plant_Count__c != null ? garden.CAMPX__Total_Plant_Count__c : 0;
            garden.CAMPX__Total_Unhealthy_Plant_Count__c = garden.CAMPX__Total_Unhealthy_Plant_Count__c != null ? garden.CAMPX__Total_Unhealthy_Plant_Count__c : 0;
            garden.CAMPX__Manager_Start_Date__c = garden.CAMPX__Manager__c != null ? Date.today() : null;
            
        }
    }

    public static void setManagerStartDate( List<CAMPX__Garden__c> newGardens, Map<Id, CAMPX__Garden__c> oldGardenMap ){
        for( CAMPX__Garden__c garden : newGardens){
            if ( (garden.CAMPX__Manager__c != null && oldGardenMap.get(garden.Id).CAMPX__Manager__c == null) 
                    || garden.CAMPX__Manager__c != oldGardenMap.get(garden.Id).CAMPX__Manager__c ){
                garden.CAMPX__Manager_Start_Date__c = Date.today();
            } else if ( garden.CAMPX__Manager__c == null) {
                garden.CAMPX__Manager_Start_Date__c = null;
            }
        }
    }

    public static void createManagerTask( List<CAMPX__Garden__c> newGardens ){

        List<Task> listTasksToInsert = new List<Task>();
        for( CAMPX__Garden__c garden : newGardens ){
            if( garden.CAMPX__Manager__c != null ){
                Task t = createTask(garden);
                listTasksToInsert.add(t);
            }
        }
        insert listTasksToInsert;
    }


    public static void createManagerTaskOnUpdate (List<CAMPX__Garden__c> newGardens, Map<Id, CAMPX__Garden__c> oldGardenMap ){

        List<Task> listTasksToInsert = new List<Task>();
        for( CAMPX__Garden__c garden : newGardens ){
            if( oldGardenMap.get(garden.Id).CAMPX__Manager__c == null && garden.CAMPX__Manager__c != null ){
                Task t = createTask(garden);
                listTasksToInsert.add(t);
            }
        }
        insert listTasksToInsert;
    }

    
    public static void reassignTaskOwnerorDeleteOnUpdate( Map<Id, CAMPX__Garden__c> newGardenMap, Map<Id, CAMPX__Garden__c> oldGardenMap ){

        List<Task> relatedTasks = [
            SELECT Id, OwnerId, WhatId, Status, Subject
            FROM Task
            WHERE WhatId IN :newGardenMap.keySet()  
            AND Subject = :DEFAULT_TASK_SUBJECT
            AND Status != 'Completed'
        ];

        Map<Id, Task> gardenIdToTaskMap = new Map<Id, Task>();
        for( Task task : relatedTasks ){
            if( !gardenIdToTaskMap.containsKey(task.WhatId) ){
                gardenIdToTaskMap.put(task.WhatId, task);
            }
        }
        
        List<Task> listTasksToUpdate = new List<Task>();
        List<Task> listTasksToDelete = new List<Task>();
        for( CAMPX__Garden__c garden : newGardenMap.values() ){

            System.debug('MANAGER ' + garden.CAMPX__Manager__c);

            Task relatedTask = gardenIdToTaskMap.get(garden.Id);
            if(relatedTask != null){

                if( garden.CAMPX__Manager__c != null && garden.CAMPX__Manager__c != oldGardenMap.get(garden.Id).CAMPX__Manager__c ){
                    relatedTask.OwnerId = garden.CAMPX__Manager__c;
                    listTasksToUpdate.add(relatedTask);
                }

                if( garden.CAMPX__Manager__c == null && oldGardenMap.get(garden.Id) != null && relatedTask.Status != 'Completed' ){
                    listTasksToDelete.add(relatedTask);
                }
            }
        }


        System.debug('***listTasksToUpdate' + listTasksToUpdate);
        System.debug('***listTasksToDelete' + listTasksToDelete);

        if(!listTasksToUpdate.isEmpty()){
            update listTasksToUpdate;
        }

        if(!listTasksToDelete.isEmpty()){
            delete listTasksToDelete;
        }

    }


    private static Task createTask( CAMPX__Garden__c garden ){
        Task t = new Task();
        t.OwnerId = garden.CAMPX__Manager__c;
        t.WhatId = garden.Id;
        t.Subject = DEFAULT_TASK_SUBJECT;
        return t;
    }
}