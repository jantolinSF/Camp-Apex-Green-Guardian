public with sharing class PlantTriggerHandler {
    
    public static void setDefaultValues(List<CAMPX__Plant__c> newPlants) {

        final String DEFAULT_SOIL_TYPE = 'All Purpose Potting Soil';
        final String DEFAULT_WATER = 'Once Weekly';
        final String DEFAULT_SUN_EXPOSURE = 'Partial Sun';
      
        Set<Id> gardenIds = new Set<Id>();
        for(CAMPX__Plant__c plant : newPlants){
            if( plant.CAMPX__Garden__c != null ){
                gardenIds.add(plant.CAMPX__Garden__c);
            }
        }

            List<CAMPX__Garden__c> relatedGardens = [
                SELECT Id, CAMPX__Sun_Exposure__c
                FROM CAMPX__Garden__c
                WHERE Id IN :gardenIds
            ];

        Map<CAMPX__Plant__c, String> mapPlantToGardenSunExposure = new Map<CAMPX__Plant__c,String>();
        for(CAMPX__Plant__c plant : newPlants ){
            for( CAMPX__Garden__c garden : relatedGardens ) {
                if (plant.CAMPX__Garden__c == garden.Id ) {
                    mapPlantToGardenSunExposure.put(plant, garden.CAMPX__Sun_Exposure__c);
                }
            }  
        }

        for(CAMPX__Plant__c plant : newPlants) {
            plant.CAMPX__Soil_Type__c = !String.isBlank(plant.CAMPX__Soil_Type__c) ? plant.CAMPX__Soil_Type__c : DEFAULT_SOIL_TYPE;
            plant.CAMPX__Water__c = !String.isBlank(plant.CAMPX__Water__c) ? plant.CAMPX__Water__c : DEFAULT_WATER;

            String sunExposure = mapPlantToGardenSunExposure.containsKey(plant) ? mapPlantToGardenSunExposure.get(plant) : null;

            if(plant.CAMPX__Garden__c == null || sunExposure == null){
                plant.CAMPX__Sunlight__c = DEFAULT_SUN_EXPOSURE;
            } else {
                 plant.CAMPX__Sunlight__c = sunExposure;
            }
        }
    }


    public static void calculateTotalPlantCount(List<CAMPX__Plant__c> newPlants){

        Set<Id> gardenIds = new Set<Id>();

        for( CAMPX__Plant__c plant : newPlants ){
            gardenIds.add(plant.CAMPX__Garden__c);
        }

        List<CAMPX__Garden__c> relatedGardens = [
            SELECT Id, CAMPX__Total_Plant_Count__c,
                ( SELECT Id, CAMPX__Garden__c FROM CAMPX__Plants__r)
            FROM CAMPX__Garden__c
            WHERE Id IN :gardenIds
        ];

        for( CAMPX__Garden__c garden : relatedGardens ){

            

        }
    }
}