app.directive('autocomplete', function($timeout,$http) {
    return {
        restrict: 'A',
            scope: {
                title: '@',
                retkey: '@',
                displaykey:'@',
                modeldisplay:'=',
                subtitle: '@',
                modelret: '='
    },

    link: function(scope, element, attrs) {
        

        scope.current = 0;
        scope.selected = false; 

        scope.fetch  = function(txt){
            console.log(txt);
            scope.loaderImg = 'loadImage';
            $http({method: 'Get', url: 'functions/candidates/search_candidates.php?tags='+txt}).
                success(function(data, status) {

                    scope.search_result = data.result;
                    scope.loaderImg = '';
                }) ;  

        var key = {left: 37, up: 38, right: 39, down: 40 , enter: 13, esc: 27, tab: 9};

        // document.addEventListener("keydown", function(e){

        //     var keycode = e.KeyCode || e.which;

        //     switch (keycode){
        //       case key.esc:
        //         // disable suggestions on escape
                
        //         scope.handleSelection(0);
                
        //     }
        // }, true);


        element[0].addEventListener("keydown",function (e){
            var keycode = e.KeyCode || e.which;

            var array_length = scope.search_result.length;
            
            // implementation of the up and down movement in the list of suggestions
            switch (keycode){
                case key.up:
                    index = scope.current;
                    console.log('up');
                    console.log(index);
                    if(index<-1){
                      index = array_length-1;
                    } else if (index >= array_length ){
                      index = -1;
                      scope.setCurrent(index);
                      break;
                    }
                    scope.setCurrent(index);

                    scope.$apply();

                    break;
                case key.down:                    
                    index = scope.current;
                    console.log('down');

                    if(index == array_length-1){
                        scope.setCurrent(index);
                    }
                    else {
                        scope.setCurrent(index+1);   
                    }

                    console.log(index);
                    return false;

                    break;
                case key.left:
                case key.right:
                case key.enter:
                case key.tab:
                    break;
                default:
                    return;
            }

            return false;

        });

    }

    scope.handleSelection = function(key) {
        console.log(scope.search_result[key]);
        scope.modelret = key;
        // scope.modeldisplay = val;
        scope.current = 0;
        scope.selected = true;
    }

    scope.isCurrent = function(index) {
        return scope.current == index;
    }

    scope.setCurrent = function(index) {
        scope.current = index;
    }

    },
    //template: '<input type="text" ng-model="modeldisplay" ng-KeyPress="da(modeldisplay)"  ng-keydown="selected=false"'+
    template:   '<input type="text" ng-model="modeldisplay" ng-change="fetch(modeldisplay);" style="width:100%; color:#000;" ng-class="loaderImg">'+
                '<div class="list-group table-condensed overlap" ng-hide="!modeldisplay.length || selected" style="width:100%">'+
                    '<ul>' +
                        '<li ng-repeat="(k,v) in search_result|filter:model track by $index">' +
                            '<a href="javascript:void();" class="list-group-item noTopBottomPad" '+
                            'ng-click="handleSelection(k)" style="cursor:pointer" '+
                            'ng-class="{active:isCurrent($index)}" '+
                            'ng-mouseenter="setCurrent($index)">'+
                                '{{v.first_name}}<br />'+
                                '<i>{{v.last_name}} </i>'+
                            '</a> '+
                        '</li>' +
                    '</ul>' +
                '</div>'+
                '</input>'
    };
});