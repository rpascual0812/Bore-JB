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
    .when('/register',
        {
            controller: 'Register',
            templateUrl: 'templates/register.html'
        })
    .when('/:pin',
    {
        controller: 'Profile',
        templateUrl: 'templates/profile.html'
    })
    .when('/',
    {
        controller: 'Feeds',
        templateUrl: 'templates/feeds.html'
    })
    .when('/confirm/:code',
    {
        controller: 'Confirm',
        templateUrl: 'templates/confirm.html'
    })
    .otherwise(
    {
        redirectTo: '/login'
    })
})
;