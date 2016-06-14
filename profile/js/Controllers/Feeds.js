app.controller('Feeds', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory,
                                    $timeout,
                                    UserService
								){

    $scope.apppin = md5.createHash('APPPIN');
    $scope.pitch = 'Make a pitch!';

	$scope.profile = {};

    $scope.feeds = {};
    $scope.feeds.data = 
    [
        {
            title : 'Senior Web Developer',
            time_passed : '1 week ago',
            experience : '4 years related work experience',
            skills : 'Skills Required: PHP, JQuery, Angular JS, PostgreSQL, Mongo DB'
        },
        {
            title : 'Junior Web Developer',
            time_passed : '1 month ago',
            experience : '1 years related work experience',
            skills : 'Skills Required: PHP, Javascript, MySQL'
        },
        {
            title : 'Server Administrator',
            time_passed : '2 months ago',
            experience : '5 years related work experience',
            skills : 'Skills Required: Linux, PostgreSQL'
        }
    ];
    
    init();

    function init(){
        $scope.profile.pin = UserService.get();
        
        var filter = {
            tags : ''
        }

        var promise = ProfileFactory.profile(filter);
        promise.then(function(data){
            console.log(data.data.result[0]);
            $scope.profile.status = true;
            $scope.profile.data = data.data.result[0];
        })
        .then(null, function(data){
            $scope.profile.status = false;
        });

        reload_feeds();
    }
    
    function reload_feeds(){
        $scope.feeds.data.unshift({
            title : 'Senior Game Developer',
            time_passed : '1 week ago',
            experience : '4 years related work experience',
            skills : 'Skills Required: PHP, JQuery, Angular JS, PostgreSQL, Mongo DB'
        });

        var to = $timeout(function() {
            $timeout.cancel(to);
            
            reload_feeds();

        }, 3000);
    }

    $scope.pitch_focus = function(){
        if($scope.pitch == "Make a pitch!"){
            $scope.pitch = "";
        }
    }
});