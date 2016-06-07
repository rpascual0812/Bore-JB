var app = angular.module('onload', [
                                    'ngRoute',
                                    'ngCookies',
                                    'angular-md5'
                                ]);

app.config(function($routeProvider){
    $routeProvider
    .when('/',
    {
        controller: 'Users',
        templateUrl: 'TEMPLATES/JOBSEEKERS/login.html'
    })
    .otherwise(
    {
        redirectTo: '/'
    })
})

.service('User', function ($cookies, md5) {
    var profile = {};

    profile.mobile = '';
    profile.status = false;

    return {
        get: function () {
            var _id = $cookies.get(md5.createHash('_id'));

            if(mobile === undefined){
                //skip
            }
            else {
                profile.status = true;
                profile.mobile = mobile;
            }

            return profile;
        },
        set: function () {
            var mobile = $cookies.get(md5.createHash('_id'));

            if(mobile === undefined){
                //skip
            }
            else {
                profile.status = true;
                profile.mobile = mobile;
            }

            return profile;
        }
    };
});