app.controller('Employees', function(
  										$scope,
                                        SessionFactory,
                                        EmployeesFactory,
                                        md5
  									){

    $scope.pk='';
    $scope.profile = {};
    $scope.filter = {};
    $scope.filter.status = 'Active';
    $scope.employees = {};

    init();

    function init(){
        var promise = SessionFactory.getsession();
        promise.then(function(data){
            var _id = md5.createHash('pk');
            $scope.pk = data.data[_id];

            get_profile();
            
        })
        .then(null, function(data){
            window.location = './login.html';
        });
    }

    function get_profile(){
        var filters = { 
            'pk' : $scope.pk
        };

        var promise = EmployeesFactory.profile(filters);
        promise.then(function(data){
            $scope.profile = data.data.result[0];
            employees();
        })   
    } 

    $scope.show_employees = function(){
       employees();
    }

    $scope.search_employees = function () {
        if ($scope.filter.searchstring.replace(/\s/g,'').length == 0){
            employees();
        }
        else if ($scope.filter.searchstring.length > 1){
            employees();
        }
    }

    function employees(){
        
        $scope.filter.archived = 'false';

        var promise = EmployeesFactory.fetch_all($scope.filter);
        promise.then(function(data){
            $scope.employees.status = true;
            $scope.employees.data = data.data.result;
        })
        .then(null, function(data){
            $scope.employees.status = false;
        });
    }

    $scope.export_employees = function(){
        window.open('./FUNCTIONS/Timelog/employees_export.php?pk='+$scope.filter.pk+'&datefrom='+$scope.filter.datefrom+"&dateto="+$scope.filter.dateto);
    }
});