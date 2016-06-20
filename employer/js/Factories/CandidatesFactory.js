app.factory('CandidatesFactory', function($http){
    var factory = {};
    
    factory.logout = function(data){
        var promise = $http({
            url : '../Functions/destroysession.php',
            method : 'GET'
        })

        return promise;
    }

    factory.search_candidates = function(data){
        var promise = $http({
            url : './functions/candidates/search_candidates.php',
            method : 'POST',
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
    }

    factory.feeds = function(data){
        var promise = $http({
            url : './functions/candidates/feeds.php',
            method : 'POST',
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
    }
    
    return factory;
});