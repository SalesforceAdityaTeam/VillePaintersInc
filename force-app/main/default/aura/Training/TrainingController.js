({
	doInit : function(component, event, helper) {
		var action = component.get('c.getTrainingController'); 
        action.setParams({});
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var arrayMapKeys = [];
                var result = a.getReturnValue();
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.mapValues", arrayMapKeys);
            }
        });
        $A.enqueueAction(action);
	}
})