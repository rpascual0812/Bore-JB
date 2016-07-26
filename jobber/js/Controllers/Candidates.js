app.controller('Candidates', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    CandidatesFactory
								){

	$scope.searchbox = {};
    $scope.profile = {};

    $scope.results = false;

    init();

    function init(){
        var filter = {
            pin : $routeParams.pin.replace('CHRS-','')
        }

        var promise = CandidatesFactory.profile(filter);
        promise.then(function(data){
            $scope.profile.data = data.data.result;
        })
        .then(null, function(data){
            
        });
    }

    $scope.search = function(){
    	// console.log(User.get());
    }

    $scope.searchbig = function(){
    	// User.set();
    	
    	var len = $scope.searchbox.text.length;
    	
    	if(len > 4){
    		$scope.results = true;
    	}

    	
    }
});