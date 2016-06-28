app.controller('Background', function(
									$scope
								){


    $scope.list = {};
    $scope.list.color = [
                            '#71e1af', '#ff0000', '#ff4444', '#ff6666', '#ffaaaa', '#ffeeee', 
                            '#fe806b', '#fb6653', '#f74e40', '#f43a2f', '#f02921', '#eb070e', '#e30000',
                            '#ea7c66', '#e36a57', '#dc5a49', '#d04739', '#c8382b', '#bc291e', '#ab140e'
                        ];


	$scope.background = '#71e1af';
    $scope.custom = '';

    $scope.change_color = function(color){
        $scope.background = color;
    }

    $scope.custom_changed = function(){

        $scope.background = '#' + $scope.custom.replace(/#/, '');
    }
});