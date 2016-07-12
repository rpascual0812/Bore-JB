app.controller('Register', function(
                                    $scope,
                                    RegisterFactory)
{

    $scope.form = {};
    
    $scope.register = function(){

        var promise = RegisterFactory.save($scope.form);
        promise.then(function(data){
            console.log('Registration Successful');
            
        })
        .then(null, function(data){
            //failed to save
            console.log('Register Failed');
        });

    };

});