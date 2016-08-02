/* --- Made by justgoscha and licensed under MIT license --- */

var app = angular.module('autocomplete', []);

app.directive('autocomplete', function() {
    var index = -1;

    return {
        restrict: 'E',
        scope: {
            searchParam: '=ngModel',
            suggestions: '=data',
            onType: '=onType',
            onSelect: '=onSelect',
            autocompleteRequired: '='
        },
        controller: ['$scope', function($scope){
            // the index of the suggestions that's currently selected
            $scope.selectedIndex = -1;

            $scope.initLock = true;

            // set new index
            $scope.setIndex = function(i){
                $scope.selectedIndex = parseInt(i);
            };

            this.setIndex = function(i){
                $scope.setIndex(i);
                $scope.$apply();
            };

            $scope.getIndex = function(i){
                return $scope.selectedIndex;
            };

            // watches if the parameter filter should be changed
            var watching = true;

            // autocompleting drop down on/off
            $scope.completing = false;

            // starts autocompleting on typing in something
            $scope.$watch('searchParam', function(newValue, oldValue){
                if (oldValue === newValue || (!oldValue && $scope.initLock)) {
                    return;
                }

                if(watching && typeof $scope.searchParam !== 'undefined' && $scope.searchParam !== null) {
                    $scope.completing = true;
                    $scope.searchFilter = $scope.searchParam;
                    $scope.selectedIndex = 0;
                }

                // function thats passed to on-type attribute gets executed

                if($scope.onType){
                    $scope.onType($scope.searchParam);
                }
            });

            // for hovering over suggestions
            this.preSelect = function(suggestion){

                watching = false;

                // this line determines if it is shown
                // in the input field before it's selected:
                //$scope.searchParam = suggestion;

                $scope.$apply();
                watching = true;

            };

            $scope.preSelect = this.preSelect;

            this.preSelectOff = function(){
                watching = true;
            };

            $scope.preSelectOff = this.preSelectOff;

            // selecting a suggestion with RIGHT ARROW or ENTER
            $scope.select = function(suggestion){
                if(suggestion){
                    $scope.searchParam = suggestion.title;
                    $scope.searchFilter = suggestion.details;

                    if($scope.onSelect)
                        var data = {
                            mode : 'specific',
                            suggestion : suggestion
                        }

                        $scope.onSelect(data);
                }
                //if undefined, select all
                else {
                    var data = {
                        mode : 'all',
                        suggestion : $scope.searchParam
                    }

                    $scope.onSelect(data);
                }
        
                watching = false;
                $scope.completing = false;
                
                setTimeout(function(){watching = true;},1000);
                
                $scope.setIndex(0);
            };


        }],
        
        link: function(scope, element, attrs){

            element.bind('click', function(){
                if(scope.onType){
                    scope.onType(scope.searchParam);
                }
            });

            setTimeout(function() {
                scope.initLock = false;
                scope.$apply();
            }, 250);

            var attr = '';

            // Default atts
            scope.attrs = {
                "placeholder": "start typing...",
                "class": "",
                "id": "",
                "inputclass": "",
                "inputid": ""
            };

            for (var a in attrs) {
                attr = a.replace('attr', '').toLowerCase();
                // add attribute overriding defaults
                // and preventing duplication
                if (a.indexOf('attr') === 0) {
                    scope.attrs[attr] = attrs[a];
                }
            }

            if (attrs.clickActivation) {
                element[0].onclick = function(e){
                    if(!scope.searchParam){
                        setTimeout(function() {
                            scope.completing = true;
                            scope.$apply();
                        }, 200);
                    }
                };
            }

            var key = {left: 37, up: 38, right: 39, down: 40 , enter: 13, esc: 27, tab: 9};

            document.addEventListener("keydown", function(e){
                var keycode = e.keyCode || e.which;

                switch (keycode){
                    case key.esc:
                        // disable suggestions on escape
                        //scope.select();
                        scope.setIndex(0);
                        scope.$apply();
                        // e.preventDefault();

                        scope.completing = false;                
                }
            }, true);

            document.addEventListener("blur", function(e){
                // disable suggestions on blur
                // we do a timeout to prevent hiding it before a click event is registered
                setTimeout(function() {
                    //scope.select();

                    scope.watching = false;
                    scope.completing = false;
                    
                    scope.setIndex(-1);
                    scope.$apply();
                }, 150);
            }, true);

            element[0].addEventListener("keydown",function (e){

                var keycode = e.keyCode || e.which;
                
                var l = angular.element(this).find('li').length;

                // this allows submitting forms by pressing Enter in the autocompleted field
                if(!scope.completing || l == 0) return;

                // implementation of the up and down movement in the list of suggestions
                switch (keycode){
                    case key.up:
                        index = scope.getIndex()-1;
                        
                        //index = scope.getIndex(); //removed minus for view all
                        if(index<0){
                            index = l;
                        } else if (index > l ){
                            index = 0;
                            scope.setIndex(index);
                            scope.preSelectOff();
                            scope.$apply();
                            break;
                        }

                        scope.setIndex(index);

                        if(index!==-1)
                            scope.preSelect(angular.element(angular.element(this).find('li')[index]).text());

                        scope.$apply();

                        break;
                    case key.down:
                        index = scope.getIndex()+1;
                        
                        if(index<=0){
                            index = l;
                        } else if (index > l ){
                            index = 0;
                            scope.setIndex(index);
                            scope.preSelectOff();
                            scope.$apply();
                            break;
                        }
                        scope.setIndex(index);

                        if(index!==-1)
                            scope.preSelect(angular.element(angular.element(this).find('li')[index]).text());

                        break;
                    //case key.left:
                    //    break;
                    //case key.right:
                    case key.enter:
                    //case key.tab:
                        index = scope.getIndex();
                        // scope.preSelectOff();
                        if(index !== -1) {
                            //scope.select(angular.element(angular.element(this).find('li')[index]).text());
                            scope.select(scope.suggestions[index]);
                            if(keycode == key.enter) {
                                e.preventDefault();
                            }
                        } else {
                            if(keycode == key.enter) {
                                scope.select();
                            }
                        }
                        
                        scope.setIndex(-1);
                        scope.$apply();

                        break;
                    // case key.esc:
                    //     // disable suggestions on escape
                    //     scope.select();
                    //     scope.setIndex(-1);
                    //     scope.$apply();
                    //     e.preventDefault();
                    //     break;
                    default:
                        return;
                }

            });
        },

        template: '\
            <div class="autocomplete {{ attrs.class }}" id="{{ attrs.id }}">\
                <input\
                    type="text"\
                    ng-model="searchParam"\
                    placeholder="{{ attrs.placeholder }}"\
                    class="{{ attrs.inputclass }}"\
                    id="{{ attrs.inputid }}"\
                    ng-required="{{ autocompleteRequired }}" />\
                <ul ng-show="completing && suggestions && searchFilter.length > 0">\
                    <li suggestion\
                        index="{{ $index }}"\
                        ng-class="{ active: ($index === selectedIndex) }"\
                        ng-click="select(suggestion)"\
                        class="cursor:pointer"\
                        ng-repeat="suggestion in suggestions | orderBy:\'toString()\' track by $index">\
                            <div>\
                                <div style="width:30%;float:left;">TITLE</div>\
                                <div style="width:70%;float:left;text-align:right;">{{suggestion.status}}</div>\
                                <div style="clear:both;"></div>\
                            </div>\
                            <div>\
                                <div style="width:65%;float:left;color:#949494;" ng-bind-html="suggestion.details | highlight:searchParam">{{suggestion.details}}</div>\
                                <div style="width:35%;float:left;color:#949494;">Last Position held</div>\
                                <div style="clear:both;"></div>\
                            </div>\
                    </li>\
                    <li suggestion\
                        index="{{suggestions.length}}"\
                        ng-class="{ active: (suggestions.length === selectedIndex) }"\
                        ng-click="select(suggestions[suggestions.length])"\
                        class="cursor:pointer"\
                        ><img src="../ASSETS/img/find.png" style="height:24px">View All</li>\
                </ul>\
            </div>'
        };
/*

            ng-bind-html="suggestion | highlight:searchParam"\
*/
  /*
  <li\
              suggestion\
              ng-repeat="suggestion in suggestions | filter:searchFilter | orderBy:\'toString()\' track by $index"\
              index="{{ $index }}"\
              val="{{ suggestion }}"\
              ng-class="{ active: ($index === selectedIndex) }"\
              ng-click="select(suggestion)"\
              ng-bind-html="suggestion | highlight:searchParam"></li>\
  */
});

app.filter('highlight', ['$sce', function ($sce) {
    return function (input, searchParam) {
        if (typeof input === 'function') return '';
        if (searchParam) {
            var words = '(' +
                    searchParam.split(/\ /).join(' |') + '|' +
                    searchParam.split(/\ /).join('|') +
                ')',
                exp = new RegExp(words, 'gi');
            if (words.length) {
                input = input.replace(exp, "<span class=\"highlight\">$1</span>");
            }
        }
        return $sce.trustAsHtml(input);
    };
}]);

app.directive('suggestion', function(){
    return {
        restrict: 'A',
        require: '^autocomplete', // ^look for controller on parents element
        link: function(scope, element, attrs, autoCtrl){
            element.bind('mouseenter', function() {
                autoCtrl.preSelect(attrs.val);
                autoCtrl.setIndex(attrs.index);
            });

            element.bind('mouseleave', function() {
                autoCtrl.preSelectOff();
            });
        }
    };
});
