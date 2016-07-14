app.controller('Login', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $timeout,
                                    User,
                                    ProfileFactory
								){

    $scope.pin = md5.createHash('PIN');

    $scope.user = {
        pin : '',
        password : '',
        error_msg : ''
    };

    $scope.header = {
        status : false
    }

    init();
    
    function init(){
        var pin = $cookies.get($scope.pin);
        if(pin !== undefined){
            window.location = "#/";
        }
    }

    $scope.login = function(){
        var error=0;
        if($scope.user.pin.replace(/\s/g,'') == ""){
            error++;
        }

        if($scope.user.password.replace(/\s/g,'') == ""){
            error++;
        }

    	if(error > 0){
            $scope.user.error_msg = 'Invalid PIN or Password';

            var to = $timeout(function() {
                $timeout.cancel(to);
                $scope.user.error_msg = "";
            }, 5000);
    	}
        else {
            $scope.user.error_msg = '';
            

            var promise = ProfileFactory.auth($scope.user);
            promise.then(function(data){
                window.location = "#/";
            })
            .then(null, function(data){
                $scope.user.error_msg = 'Invalid PIN or Password';

                var to = $timeout(function() {
                    $timeout.cancel(to);
                    $scope.user.error_msg = "";
                }, 5000);
            });
        }

    	// var pin = md5.createHash('PIN');
    	// var now = new Date();
        // var exp = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 8);

        // $cookies.put(pin, 'chrs201400105', { expires : exp });
    }

    $scope.onKeypress = function(){
    	$scope.login();
    	//window.location = "#/home";
    }
    
});