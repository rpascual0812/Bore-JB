app.controller('Home', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    EmployersFactory,
                                    EmployerService,
                                    SearchService
								){

    $scope.searchbox = {};
    $scope.candidates = {
        data : [],
        status : false
    };

    $scope.employer = {};
    $scope.prices = {};
    $scope.employer_bucket = [];

    $scope.pics = [
        '../ASSETS/Uploads/jobseeker/rafael1.jpg',
        '../ASSETS/Uploads/jobseeker/eli.png',
        '../ASSETS/Uploads/jobseeker/greg.jpg',
        '../ASSETS/Uploads/jobseeker/ken.jpg',
        '../ASSETS/Uploads/jobseeker/super_happy.png',
        '../ASSETS/Uploads/jobseeker/happy.png',
        '../ASSETS/Uploads/jobseeker/tongue.png',
        '../ASSETS/Uploads/jobseeker/female1.jpg',
        '../ASSETS/Uploads/jobseeker/female2.png',
        '../ASSETS/Uploads/jobseeker/female3.png'
    ];
    //

    init();

    $scope.$watch(EmployerService.get(), function(newVal, oldVal) {
        if(newVal == false){
            alert('Your session has timed out.');
        }
    }, true);

    function init(){
        var result = checkpin();
    	if(result == false){
    		window.location = "#/login";
    	}
        else {
            get_profile();

            feeds();
            //set_search_box();
        }
    }

    function feeds(){
        var filter = {
            archived : false
        };

        var promise = CandidatesFactory.feeds(filter);
        promise.then(function(data){
            $scope.candidates.data = [];
            $scope.candidates.data = data.data.result;

            for(var i in $scope.candidates.data){
                $scope.candidates.data[i].pic = $scope.pics[[Math.floor(Math.random() * $scope.pics.length)]];
            }

            $scope.candidates.status = true;
        })
        .then(null, function(data){
            $scope.candidates.status = false;
        });
    }

    $scope.logout = function(){
        var promise = CandidatesFactory.logout();
        promise.then(function(data){
            window.location = "#/login";
        })
    }

    function checkpin(){
        var pin = EmployerService.get();
        return pin;
    }

    function get_profile(){
        var filter = {
            pin : EmployerService.get()
        }

        var promise = EmployersFactory.profile(filter);
        promise.then(function(data){
            $scope.employer = data.data.result[0];

            get_prices();
            get_employer_bucket();
        })
    }

    function get_prices(){
        var filter = {
            currencies_pk : $scope.employer.currencies_pk
        }

        var promise = EmployersFactory.prices(filter);
        promise.then(function(data){
            var a = data.data.result;
            
            for(var i in a){
                $scope.prices[a[i].type] = parseFloat(a[i].price);
            }
        })
    }

    function get_employer_bucket(){
        var filter = {
            pin : $scope.employer.pin
        }

        var promise = EmployersFactory.employer_bucket(filter);
        promise.then(function(data){
            var a = data.data.result;

            for(var i in a){
                $scope.employer_bucket.push(a[i].applicant_id)    
            }
        })
    }

    $scope.searchbig = function(){
        searchbig();
    }

    function searchbig(){
        var result = checkpin();
        if(result == false){
            window.location = "#/login";
        }
        else {
            var filter = {
                tags : $scope.searchbox.text
            };

            var len = $scope.searchbox.text.length;
            if(len > 2){
                SearchService.set($scope.searchbox.text);
                var promise = CandidatesFactory.search_candidates(filter);
                promise.then(function(data){                
                    $scope.candidates.data = data.data.result;
                    $scope.candidates.status = true;
                })
                .then(null, function(data){
                    $scope.candidates.status = false;
                });
            }
        }
    }

    function set_search_box(){
        var search_text = SearchService.get();
        
        if(search_text != null){
            $scope.searchbox.text = search_text;
            searchbig();
        }
    }

    $scope.request_cv = function(applicant_id){
        if($scope.employer.plan == 'Standard'){
            if(parseFloat($scope.employer.available) >= $scope.prices.CV){
                if(!contains($scope.employer_bucket, applicant_id)){
                    update_credit();
                    update_employer_bucket(applicant_id);
                }

                window.location = '#/candidate/CHRS-'+applicant_id;
            }
            else {
                alert('Low credit balance');
            }
        }
        else if($scope.employer.plan == 'Premium'){
            window.location = '#/candidate/CHRS-'+applicant_id;
        }
    }

    function update_credit(){
        var filter = {
            pin : $scope.employer.pin,
            deduction : $scope.prices.CV
        }

        var promise = EmployersFactory.update_credit(filter);
        promise.then(function(data){                
            //console.log(data.data);
            //do nothing for now
        })
    }

    function update_employer_bucket(applicant_id){
        var filter = {
            pin : $scope.employer.pin,
            applicant_id : applicant_id
        }

        var promise = EmployersFactory.update_employer_bucket(filter);
        promise.then(function(data){
            //console.log(data.data);
            //do nothing for now
        })   
    }

    $scope.videochat = function(){
        window.open('https://apprtc.appspot.com/r/chrswebrtc');
    }
});