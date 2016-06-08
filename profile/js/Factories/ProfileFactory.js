app.factory('ProfileFactory', function($http){
    var factory = {};

    factory.profile = function(data){
        var promise = $http({
            url:'./functions/profile/fetch.php',
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