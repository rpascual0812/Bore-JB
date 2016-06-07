app.factory('EmployersFactory', function($http){
    var factory = {};           
    
    factory.auth = function(data){
        var promise = $http({
            url:'./functions/employers/auth.php',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            transformRequest: function(obj) {
                var str = [];
                for(var p in obj)
                str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                return str.join("&");
            },
            data : data
        })

        return promise;
    };
    
    return factory;
});