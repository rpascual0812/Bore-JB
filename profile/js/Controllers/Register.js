app.controller('Register', function(
                                    $scope,
                                    RegisterFactory
                                    )
{

    $scope.form = {};

    $scope.register = function(){
        var promise = RegisterFactory.save($scope.form);
        promise.then(function(data){
            console.log('Registration Successful');
            window.location = "#";
        })
        .then(null, function(data){
            //failed to save
            console.log('Register Failed');
        });
    };

    $scope.checkEmail = function(){
        checkEmail();
    }

    function checkEmail() {
        console.log($scope.form);

        var data = {
            email : $scope.form.email
        };

        var promise = RegisterFactory.get(data);
        promise.then(function(data){
            console.log("E-mail already taken..");
            document.getElementById("register").setAttribute("disabled", "disabled");
        })
        .then(null, function(data){
            //
            console.log("E-mail available");
        });
    }

});