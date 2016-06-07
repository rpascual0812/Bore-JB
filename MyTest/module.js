var app = angular.module
(
    'onload', 
    [
    ]
)

app.config(function($routeProvider){
    $routeProvider
    .when
    ('/',
        {
            controller: 'Home',
            templateUrl: 'index.html'
        }
    )
    
    .otherwise
    (
        {
            redirectTo: '/'
        }
    )
})