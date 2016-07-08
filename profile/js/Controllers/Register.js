app.controller('Register', function(
                                    $scope,
                                    RegisterFactory)
{

    $scope.form = {};

    $scope.register = function(){
        var errCtr = 0;
        
        if ($scope.form.password1 !== $scope.form.password2) {
            errCtr++;
            console.log("Password Mismatch");
        }

        if (!validateEmail($scope.form.email)) {
            errCtr++;
            console.log("Invalid Email");
        }

        
        if (errCtr > 0) {
            console.log('Register Failed..' + errCtr);
        }
        else {
            var promise = RegisterFactory.save($scope.form);
            promise.then(function(data){
                console.log('Registration Successful');
                
            })
            .then(null, function(data){
                //failed to save
                console.log('Register Failed');
            });
        }
    };

    function validateEmail(email) {
        var regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return regex.test(email);
    }

});