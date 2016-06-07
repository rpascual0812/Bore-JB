app.controller('Header', function(
									$scope,
									$cookies,
                                    User,
                                    md5                                    
								){

	$scope.header = {
		status : false
	}

	$scope.$watch(User.get(), function(newVal) {
        if(User.get() === undefined){
            $scope.header.status = false;
        }
        else {
        	$scope.header.status = true;	
        }
    }, true);
});