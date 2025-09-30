// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

//System.debug(FoodOrderController.getFoodItems());
Map<Decimal,Map<Decimal,String>> myMap=new Map<Decimal,Map<Decimal,String>>();
myMap.put(12,new Map<Decimal,String>());
myMap.get(12).put(12,'vro');
mymap.get(12).put(33,'jfao');
for(Decimal key:myMap.keySet()){
    for(Decimal key2:myMap.get(key).keySet()){
        System.debug(myMap.get(key).get(key2));
    }
}

Map<Decimal,List<Map<Decimal,String>>> complexMap=new Map<Decimal,List<Map<Decimal,String>>>();
complexMap.put(12,new List<Map<Decimal,String>>());
Map<Decimal, String> innerMap1 = new Map<Decimal, String>();
innerMap1.put(1, 'One');
innerMap1.put(2, 'Two');

// Create second inner map
Map<Decimal, String> innerMap2 = new Map<Decimal, String>();
innerMap2.put(3, 'Three');
innerMap2.put(4, 'Four');

// Add both inner maps to the list for key 12
complexMap.get(12).add(innerMap1);
complexMap.get(12).add(innerMap2);
