app.controller('Employers', function(
                                        $scope,
                                        EmployersFactory
                                    ){

    $scope.profiles = {};
    $scope.employers = {};

    new_employers();

    function new_employers(){
        var promise = EmployersFactory.fetch();
        promise.then(function(data){
            var a = data.data.result;
            $scope.profiles=[];
            for(var i in a){
            $scope.name = JSON.parse(a[i].profile);
                $scope.profiles.push({
                                        pin: a[i].pin,
                                        date_created: a[i].date_created,
                                        first_name: $scope.name.personal.first_name,
                                        last_name: $scope.name.personal.last_name,
                                        //company_name: a[i].company_name,
                                        //email_address: $scope.name.personal.email_address
                })
                console.log($scope.name.personal.first_name)
            }

            //$scope.profiles.data = data.data.result;
            //$scope.profiles.data.profiles = (JSON.parse($scope.profiles.data[0].profile));
            //var first_name = $scope.profiles.data.profiles.personal.first_name;
            //$scope.profiles.data.first_name = first_name;
            //console.log($scope.profiles.data.profiles.personal.first_name)
            
        })
        .then(null, function(data){
            //failed to retrieving data
        });  
    }

});