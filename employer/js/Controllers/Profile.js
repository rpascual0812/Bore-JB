app.controller('Profile', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory
								){

    $scope.emppin = md5.createHash('PIN');

    $scope.searchbox = {};
    $scope.user = {
        applicant : {
            status : false,
            pin : null
        },
        employer : {
            status : false,
            pin : null
        }
    };

	$scope.profile = {};
    
    init();

    function init(){

        $scope.profile.pin = $routeParams.apppin;
        var filter = {
            applicant_id : $routeParams.apppin.replace('CHRS-', '')
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
    }

    
});