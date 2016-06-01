var app = angular.module('onload', [
                                    'ngRoute',
                                    'ngCookies',
                                    'angular-md5'
                                ]);

app.config(function($routeProvider){
    $routeProvider
    .when('/login',
    {
        controller: 'Login',
        templateUrl: 'templates/login.html'
    })
    .when('/',
    {
        controller: 'Candidates',
        templateUrl: 'templates/candidates.html'
    })
    .when('/:pin',
    {
        controller: 'Candidates',
        templateUrl: 'templates/profile.html'
    })
    .otherwise(
    {
        redirectTo: '/'
    })
})

.service('Employer', function ($cookies, md5) {
    return {
        get: function(){
            var pin = $cookies.get(md5.createHash('PIN'));   

            if(pin === undefined){
                //skip
            }
            else {
                return pin;
            }
        },
        set: function(){
            var pin = md5.createHash('PIN');
            var now = new Date()
            var exp = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 8);
            $cookies.put(pin, 'chrs201400104', { expires : exp });
        }
    };
})

.service('Jobseeker', function ($cookies, md5) {
    return {
        get: function(){
            var pin = $cookies.get(md5.createHash('PIN'));   

            if(pin === undefined){
                //skip
            }
            else {
                return pin;
            }
        },
        set: function(){
            var pin = md5.createHash('PIN');
            var now = new Date()
            var exp = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 8);
            $cookies.put(pin, 'chrs201400104', { expires : exp });
        }
    };
});