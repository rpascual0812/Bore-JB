app.directive('isLetters', function () {
    return {
    require: '?ngModel',
    link: function(scope, element, attrs, ngModelCtrl) {
        if(!ngModelCtrl) {
            return;
        }

        ngModelCtrl.$parsers.push(function(val) {
            if (angular.isUndefined(val)) {
                var val = '';
            }
            var clean = val.replace( /[^a-z|A-Z]+/g, '');
            if (val !== clean) {
                ngModelCtrl.$setViewValue(clean);
                ngModelCtrl.$render();
            }
            return clean;
        });

        element.bind('keypress', function(event) {
            if(event.keyCode === 32) {
                event.preventDefault();
            }
        });
    }
    };
});