app.controller('Posts', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    EmployersFactory,
                                    EmployerService
								){

    $scope.candidates = {
        data : [],
        status : false
    };

    $scope.feeds = {};
    
    $scope.newad = {
        create : true,
        link : false,
        post : false
    };

    $scope.movies = ["The Wolverine", "The Smurfs 2", "The Mortal Instruments: City of Bones", "Drinking Buddies", "All the Boys Love Mandy Lane", "The Act Of Killing", "Red 2", "Jobs", "Getaway", "Red Obsession", "2 Guns", "The World's End", "Planes", "Paranoia", "The To Do List", "Man of Steel"];

    $scope.feeds.data = 
    [
        {
            image : '../ASSETS/Uploads/employers/accenture3.png',
            title : 'Senior Web Developer',
            time_passed : '1 week ago',
            experience : '4 years related work experience',
            skills : 'Skills Required: PHP, JQuery, Angular JS, PostgreSQL, Mongo DB',
            ad : {
                link : 'https://www.youtube.com/embed/n9EgH-QxaUI',
                type : 'youtube'
            }
        },
        {
            image : '../ASSETS/Uploads/employers/ibex2.png',
            title : 'Junior Web Developer',
            time_passed : '1 month ago',
            experience : '1 years related work experience',
            skills : 'Skills Required: PHP, Javascript, MySQL',
            ad : {
                link : '../ASSETS/Uploads/ads/ad1.gif',
                type : 'gif'
            }
        },
        {
            image : '../ASSETS/Uploads/employers/uhg2.jpeg',
            title : 'Server Administrator',
            time_passed : '2 months ago',
            experience : '5 years related work experience',
            skills : 'Skills Required: Linux, PostgreSQL',
            ad : {
                link : 'https://13blackandwhitescribbles.files.wordpress.com/2015/09/uhg.jpg',
                type : 'image'
            }
        }
    ];

    init();

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

	function feeds(){
        var filter = {
            archived : false
        };

        var promise = CandidatesFactory.feeds(filter);
        promise.then(function(data){
            $scope.candidates.data = [];
            $scope.candidates.data = data.data.result;
            $scope.candidates.status = true;
        })
        .then(null, function(data){
            $scope.candidates.status = false;
        });
    }

    $scope.navigate_ads = function(type){
        for(var i in $scope.newad){
            $scope.newad[i] = false;
        }

        $scope.newad[type] = true;
    }
});