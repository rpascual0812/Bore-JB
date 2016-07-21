app.controller('Register', function(
                                    $scope,
                                    RegisterFactory)
{

    $scope.form = {};

    $scope.register = function(){
        var errCtr = 0;

        if (!validateEmail($scope.form.email_address)) {
            errCtr++;
            console.log("Invalid Email");
        }

        
        if (errCtr > 0) {
            alert('Oops! there is some input errors, check your email!');
        }
        else {
            var promise = RegisterFactory.save($scope.form);
            promise.then(function(data){
                window.location = "#sent";
            })
        }
    };

    function validateEmail(email) {
        var regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return regex.test(email);
    }

});