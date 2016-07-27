var app = angular.module('onload', [
                                    'ngRoute',
                                    'ngCookies',
                                    'angular-md5',
                                    'textAngular',
                                    'ui.tinymce',
                                    'autocomplete',
                                    'ngTagsInput',
                                    'ui.mask'
                                ]);

app.config(function($routeProvider){
    $routeProvider
    .when('/login',
    {
        controller: 'Login',
        templateUrl: 'templates/login.html'
    })
    .when('/candidate/:apppin',
    {
        controller: 'Profile',
        templateUrl: 'templates/profile.html'
    })
    .when('/posts',
    {
        controller: 'Posts',
        templateUrl: 'templates/posts.html'
    })
    .when('/register',
    {
        controller: 'Register',
        templateUrl: 'templates/registration.html'
    })
    .when('/sent',
    {
        controller: 'Register',
        templateUrl: 'templates/sent.html'
    })
    .when('/admin/companies/new',
    {
        controller: 'Employers',
        templateUrl: 'templates/admin/new_employers.html'
    })
    .when('/',
    {
        controller: 'Home',
        templateUrl: 'templates/home.html'
    })
    .otherwise(
    {
        redirectTo: '/'
    })
})

.service('User', function ($cookies, md5) {
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

function contains(a, obj) {
    var i = a.length;
    while (i--) {
        console.log(a[i] +" <> "+ obj);
        if (a[i] === obj) {
            return true;
        }
    }

    return false;
}

app.directive('autoComplete', function($timeout) {
    return function(scope, iElement, iAttrs) {
            iElement.autocomplete({
                source: scope[iAttrs.uiItems],
                select: function() {
                    $timeout(function() {
                      iElement.trigger('input');
                    }, 0);
                }
            });
    };
});