app.controller('Candidates', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    User
								){

    $scope.pin = md5.createHash('PIN');

	$scope.searchbox = {};
    $scope.candidates = {
        data : [],
        status : false
    };

    init();

    function init(){
    	var pin = $cookies.get($scope.pin);
    	if(pin === undefined || pin.replace(/\s/g,'') == ""){
    		window.location = "#/login";
    	}
    }

    $scope.search = function(){
    	console.log(User.get());
    }

    $scope.searchbig = function(){
    	var filter = {
            tags : $scope.searchbox.text
        };

    	var len = $scope.searchbox.text.length;
    	if(len > 2){
    		var promise = CandidatesFactory.search_candidates(filter);
            promise.then(function(data){                
                $scope.candidates.data = data.data.result;
                $scope.candidates.status = true;
            })
            .then(null, function(data){
                $scope.candidates.status = false;
            });
    	}
    }

    $scope.logout = function(){
        var promise = CandidatesFactory.logout();
        promise.then(function(data){
            window.location = "#/login";
        })
    }
});