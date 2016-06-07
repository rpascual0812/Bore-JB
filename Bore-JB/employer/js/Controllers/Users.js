app.controller('Users', function(
									$scope,
                                    md5,
                                    $cookies
								){

    $scope.user = {};


    $scope.login = function(keyEvent){
    	console.log(keyEvent);


    	// var hash = md5.createHash('mobile');
     //    var mobile_number = $cookies.get(hash);

    	// var pin = md5.createHash('pin');
    	// var now = new Date()
     //    var exp = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 1);

     //    $cookies.put(pin, '', { expires : exp });


    	//
    }

    $scope.onKeypress = function(){
    	$scope.login();
    	//window.location = "#/home";
    }
    
});