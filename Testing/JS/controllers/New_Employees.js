app.controller('New_Employees', function(
  										$scope,
                                        SessionFactory,
                                        EmployeesFactory,
                                        md5
  									){

    $scope.pk='';
    $scope.titles={};
    $scope.department={};
    $scope.employee={};
    $scope.filter={};

    init();

    function init(){
        var promise = SessionFactory.getsession();
        promise.then(function(data){
            var _id = md5.createHash('pk');
            $scope.pk = data.data[_id];

            get_positions();
            get_department();
            /*submit_employee();*/

            
        })
        .then(null, function(data){
            window.location = './login.html';
        });
    }

    function get_positions(){
        var promise = EmployeesFactory.get_positions();
        promise.then(function(data){
            $scope.titles.data = data.data.result;
        })
        .then(null, function(data){
            
        });
    }

    function get_department(){
        var promise = EmployeesFactory.get_department();
        promise.then(function(data){
            $scope.department.data = data.data.result;
        })
        .then(null, function(data){
            
        });
    }

    $scope.submit_employee = function(){
        var promise = EmployeesFactory.submit_employee($scope.employee);
        promise.then(function(data){
            $scope.employee.data = data.data.result;

        })
        .then(null, function(data){
            
        });
    }

});