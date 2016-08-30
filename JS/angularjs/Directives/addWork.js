app.directive('addWork', ['$compile', function ($compile) { // inject $compile service as dependency
	return {
		restrict: 'AE',
		link: function (scope, element, attrs){

			element.find('button').bind('click', function () {
				var work = angular.element('<table id="'+scope.inputCounter+'"><tr><td colspan=2><hr><a href="" ng-click="removeElement('+scope.inputCounter+')">Remove</a></td></tr><div><tr><td colspan=2></td></tr><tr><td class="labels"><label>Company:</label></td><td><input style="width: 56%; margin-right:2%;  border-right:none; border-left:none;border-top:none;border-bottom: 2px solid #f46963;"  type="text" name="company" placeholder="Company" ng-model="extended.company['+scope.inputCounter+']" tabindex=  required/></td></tr><tr><td class="labels"></td><td><span style="color:#a81c17; font-size: 13px;" ng-show="work_form.company.$invalid && !work_form.company.$pristine">*Company is required</span></td></tr><tr><td class="labels"><label>Position:</label></td><td><input style="width: 56%; margin-right:2%;  border-right:none; border-left:none;border-top:none;border-bottom: 2px solid #f46963;" type="text" name="position" placeholder="Position" ng-model="extended.position['+scope.inputCounter+']" tabindex=  required/></td></tr><tr><td class="labels"></td><td><span style="color:#a81c17; font-size: 13px;" ng-show="work_form.position.$invalid && !work_form.position.$pristine">*Position is required</span></td></tr><tr><td class="labels"><label>Date From:</label></td><td><select class="dropdown" ng-model="extended.start_date.month['+scope.inputCounter+']" name="month" default="Month" style="margin-right:2%;" tabindex= ><option value="" disabled selected style="display:none" >Month</option><option ng-repeat="v in months" value="{{v}}">{{v}}</option></select><select class="dropdown" ng-model="extended.start_date.day['+scope.inputCounter+']" name="day" default="Day" style="margin-right:2%; " tabindex= required><option value="" disabled selected style="display:none">Day</option><option ng-repeat="v in days" value="{{v}}">{{v}}</option></select><input style=" width: 16%; margin-right:2%; border-right:none; border-left:none;border-top:none;border-bottom: 2px solid #f46963;" type="text" name="year" placeholder="Year" ng-model="extended.start_date.year['+scope.inputCounter+']" is-number maxlength=4 tabindex=/></td></tr><tr><td class="labels"></td><td><input type="checkbox" ng-model="extended.isEmployed['+scope.inputCounter+']" value="Employed" ng-change="isEmployed(extended.isEmployed['+scope.inputCounter+'])" tabindex= enter-key><label> Present</label></input></td></tr><tr><td class="labels"><div ng-class="work_end"><label>Date To:</label></td></div><td><div ng-class="work_end"><select class="dropdown" ng-model="employed_extended['+scope.inputCounter+']" name="month" default="Month" style="margin-right:2%;" tabindex= ><option value="" disabled selected style="display:none">Month</option><option ng-repeat="v in months" value="{{v}}">{{v}}</option></select><select class="dropdown" ng-model="extended.end_date.day['+scope.inputCounter+']" name="day" default="Day" style="margin-right:2%; " tabindex=><option value="" disabled selected style="display:none">Day</option><option ng-repeat="v in days" value="{{v}}">{{v}}</option></select><input style=" width: 16%; margin-right:2%; border-right:none; border-left:none;border-top:none;border-bottom: 2px solid #f46963;" type="text" name="year" placeholder="Year" ng-model="extended.end_date.year['+scope.inputCounter+']" is-number maxlength=4 tabindex=/></div></td></tr><tr><td class="labels"><label>Experience<br>Description:</label></td><td><textarea style="background-color: #FCFCFC;border:none;width:78%;" name="experience_description" rows="5" ng-model="extended.experience_description['+scope.inputCounter+']" placeholder="Accomplishments, notable projects, etc." tabindex=></textarea></td></tr><tr><td class="labels"></td><td></td></tr></div>');
				var compile = $compile(work)(scope);
				element.append(work);
				
			    scope.completed_extend[scope.inputCounter]="ng-show";
			    scope.present_extend[scope.inputCounter]="ng-hide";
				scope.inputCounter++;


				
    			

			});
		}
	}
}]);