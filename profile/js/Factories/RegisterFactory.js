app.factory('RegisterFactory', function($http){
    var factory = {};

    factory.save = function(data){
        var promise = $http({
            url:'./functions/profile/register.php',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            transformRequest: function(obj) {
                var str = [];
                for(var p in obj)
                str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                return str.join("&");
            },
            data : data
        });

        return promise;
    };

    factory.get = function(data){
        var promise = $http({
            url:'./functions/profile/regfetch.php',
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            transformRequest: function(obj) {
                var str = [];
                for(var p in obj)
                    str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
                return str.join("&");
            },
            data : data
        });

        return promise;
    };

    return factory;
});