app.controller('Profile', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory
								){

    $scope.apppin = md5.createHash('APPPIN');

	$scope.profile = {};
    
    init();

    function init(){
        $scope.profile.pin = $routeParams.pin;
        var filter = {
            applicant_id : $routeParams.pin.replace('CHRS-', '')
        }
        
        var promise = ProfileFactory.profile(filter);
        promise.then(function(data){
            $scope.profile.status = true;
            console.log($scope.profile.data);
            $scope.profile.data = data.data.result[0];

            $scope.profile.data.currency = 'PHP';
            $scope.profile.data.available = '0.00';
        })
        .then(null, function(data){
            $scope.profile.status = false;
        });
    }
    
});