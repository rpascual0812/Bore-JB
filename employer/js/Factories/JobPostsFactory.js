app.factory('JobPostsFactory', function($http){
    var factory = {};           

    factory.post_job = function(data){
        var promise = $http({
            url:'./functions/employers/post_job.php',
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