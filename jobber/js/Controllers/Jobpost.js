app.controller('Jobpost', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory,
                                    JobPostsFactory,
                                    $timeout,
                                    PINService
								){

    $scope.apppin = md5.createHash('APPPIN');

	$scope.profile = {};

    $scope.job_post = {};

    init();

    function init(){
        var result = checkpin();
        if(result == false){
            window.location = "#/login";
        }
        else {
            get_profile();
        }
    }

    function checkpin(){
        var pin = PINService.get();
        return pin;
    }

    function get_profile(){
        var filter = {
            pin : PINService.get()
        };
        
        var promise = ProfileFactory.profile(filter);
        promise.then(function(data){
            $scope.profile = data.data.result[0];
            $scope.profile.profile = JSON.parse($scope.profile.profile);
            
            job_post();
        });
    }

    function job_post(){
        var filter = {
            pk : $routeParams.id
        };

        var promise = JobPostsFactory.job_post(filter);
        promise.then(function(data){
            $scope.job_post.status = true;
            $scope.job_post.data = data.data.result[0];
            $scope.job_post.data.details = JSON.parse($scope.job_post.data.details);

            console.log($scope.job_post.data);
        })
        .then(null, function(data){
            $scope.job_post.status = false;
        });
    }
});