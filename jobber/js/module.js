var app = angular.module('onload', [
                                    'ngRoute',
                                    'ngCookies',
                                    'angular-md5',
                                    'ui.mask',
                                    'autocomplete'
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
    .when('/messages',
        {
            controller: 'Messages',
            templateUrl: 'templates/messages.html'
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
    .when('/ad/:id',
    {
        controller: 'Jobpost',
        templateUrl: 'templates/jobpost.html'
    })
    .otherwise(
    {
        redirectTo: '/login'
    })
})
;