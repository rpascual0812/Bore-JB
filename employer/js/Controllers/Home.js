app.controller('Home', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    EmployersFactory,
                                    PINService,
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

    $scope.movies = [
                        "Lord of the Rings",
                        "Drive",
                        "Science of Sleep",
                        "Back to the Future",
                        "Oldboy"
                    ];

    init();

    // $scope.$watch(PINService.get(), function(newVal, oldVal) {
    //     if(newVal == false){
    //         alert('Your session has timed out.');
    //     }
    // }, true);


    function init(){
        var result = checkpin();
    	if(result == false){
    		window.location = "#/login";
    	}
        else {
            get_profile();

            feeds();
            //set_search_box();

            initialize_search();
        }
    }

    function initialize_search(){

    }

    $scope.doSomething = function(typedthings){
        $scope.movies = ["The Wolverine", "The Smurfs 2", "The Mortal Instruments: City of Bones", "Drinking Buddies", "All the Boys Love Mandy Lane", "The Act Of Killing", "Red 2", "Jobs", "Getaway", "Red Obsession", "2 Guns", "The World's End", "Planes", "Paranoia", "The To Do List", "Man of Steel", "The Way Way Back", "Before Midnight", "Only God Forgives", "I Give It a Year", "The Heat", "Pacific Rim", "Pacific Rim", "Kevin Hart: Let Me Explain", "A Hijacking", "Maniac", "After Earth", "The Purge", "Much Ado About Nothing", "Europa Report", "Stuck in Love", "We Steal Secrets: The Story Of Wikileaks", "The Croods", "This Is the End", "The Frozen Ground", "Turbo", "Blackfish", "Frances Ha", "Prince Avalanche", "The Attack", "Grown Ups 2", "White House Down", "Lovelace", "Girl Most Likely", "Parkland", "Passion", "Monsters University", "R.I.P.D.", "Byzantium", "The Conjuring", "The Internship"];
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
        var pin = PINService.get();
        return pin;
    }

    function get_profile(){
        var filter = {
            pin : PINService.get()
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
            if($scope.searchbox.text === undefined){
                return false;
            }

            var filter = {
                tags : $scope.searchbox.text
            };

        //     var len = $scope.searchbox.text.length;
        //     if(len > 2){
        //         //SearchService.set($scope.searchbox.text);
                var promise = CandidatesFactory.search_candidates(filter);
                promise.then(function(data){   
                    console.log(data.data.result);
                    // $scope.candidates.data = data.data.result;
                    // console.log($scope.candidates.data);
                    // $scope.candidates.status = true;
                })
                .then(null, function(data){
                    $scope.candidates.status = false;
                });
        //     }
        }
    }

    function set_search_box(){
        var search_text = SearchService.get();
        
        if(search_text != null){
            $scope.searchbox.text = search_text;
            //searchbig();
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