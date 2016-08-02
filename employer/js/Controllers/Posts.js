app.controller('Posts', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    EmployersFactory,
                                    PINService,
                                    JobPostsFactory,
                                    Upload,
                                    $timeout
								){

    $scope.candidates = {
        data : [],
        status : false
    };

    //MENU
    $scope.newad = {
        create : true,
        link : false,
        post : false
    };

    //FORMS
    $scope.new_job_post = {};
    $scope.new_job_post.ad = {};
    $scope.new_job_post.video = {};
    $scope.new_job_post.job = {};

    //LIST OF PREVIOUS POSTS
    $scope.job_posts = {};
    $scope.job_posts.data = [];

    $scope.picFile = null;
    
    // $scope.job_posts.data = 
    // [
    //     {
    //         image : '../ASSETS/Uploads/employers/accenture3.png',
    //         title : 'Senior Web Developer',
    //         time_passed : '1 week ago',
    //         experience : '4 years related work experience',
    //         skills : 'Skills Required: PHP, JQuery, Angular JS, PostgreSQL, Mongo DB',
    //         ad : {
    //             link : 'https://www.youtube.com/embed/n9EgH-QxaUI',
    //             type : 'youtube'
    //         }
    //     },
    //     {
    //         image : '../ASSETS/Uploads/employers/ibex2.png',
    //         title : 'Junior Web Developer',
    //         time_passed : '1 month ago',
    //         experience : '1 years related work experience',
    //         skills : 'Skills Required: PHP, Javascript, MySQL',
    //         ad : {
    //             link : '../ASSETS/Uploads/ads/ad1.gif',
    //             type : 'gif'
    //         }
    //     },
    //     {
    //         image : '../ASSETS/Uploads/employers/uhg2.jpeg',
    //         title : 'Server Administrator',
    //         time_passed : '2 months ago',
    //         experience : '5 years related work experience',
    //         skills : 'Skills Required: Linux, PostgreSQL',
    //         ad : {
    //             link : 'https://13blackandwhitescribbles.files.wordpress.com/2015/09/uhg.jpg',
    //             type : 'image'
    //         }
    //     }
    // ];

    $scope.prices = {};
    $scope.employer_bucket = [];

    $scope.movies = ["The Wolverine", "The Smurfs 2", "The Mortal Instruments: City of Bones", "Drinking Buddies", "All the Boys Love Mandy Lane", "The Act Of Killing", "Red 2", "Jobs", "Getaway", "Red Obsession", "2 Guns", "The World's End", "Planes", "Paranoia", "The To Do List", "Man of Steel"];

    $scope.tinymceOptions = {
        menubar : false,
        plugins: 'link image code advlist lists placeholder',
        toolbar: 'styleselect formatselect fontselect fontsizeselect | undo redo | cut copy paste | bold italic underline | bullist numlist alignleft aligncenter alignright alignjustify '
    };

    $scope.picFile = {};

    /*
    toolbar: "bold italic underline strikethrough| undo redo",//" | cut copy paste | styleselect print forecolor backcolor",
    toolbar1: "bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect formatselect fontselect fontsizeselect",
    toolbar2: "cut copy paste | bullist numlist | outdent indent blockquote | undo redo | anchor | forecolor backcolor",
    */

    init();

    function init(){
        var result = checkpin();
        if(result == false){
            window.location = "#/login";
        }
        else {
            get_profile();

            job_posts();
            //set_search_box();
        }
    }

    function checkpin(){
        var pin = PINService.get();
        return pin;
    }

    function get_profile(){
        var filter = {
            pin : PINService.get()
        }

        var promise = EmployersFactory.fetch(filter);
        promise.then(function(data){
            $scope.employer = data.data.result[0];

            get_prices();
            get_employer_bucket();
        })
    }

    $scope.bigsearch_changed = function(str){
        if(str.replace(/\s/g, '') == ''){
            return false;
        }

        var filter = {
            'str' : str
        };

        $scope.candidates.data = [];
        var promise = CandidatesFactory.search_candidates(filter);
        promise.then(function(data){
            var a = data.data.result;
            
            for(var i in a){
                a[i].profile = JSON.parse(a[i].profile);

                $scope.candidates.data.push({
                                                title : a[i].pin,
                                                status : a[i].status,
                                                details : a[i].profile.skills.join(', ')
                                            });
            }
        })
        .then(null, function(data){
            $scope.candidates.status = false;
        });

        //$scope.candidates.data = ["The Wolverine", "The Smurfs 2", "The Mortal Instruments: City of Bones", "Drinking Buddies", "All the Boys Love Mandy Lane", "The Act Of Killing", "Red 2", "Jobs", "Getaway", "Red Obsession", "2 Guns", "The World's End", "Planes", "Paranoia", "The To Do List", "Man of Steel", "The Way Way Back", "Before Midnight", "Only God Forgives", "I Give It a Year", "The Heat", "Pacific Rim", "Pacific Rim", "Kevin Hart: Let Me Explain", "A Hijacking", "Maniac", "After Earth", "The Purge", "Much Ado About Nothing", "Europa Report", "Stuck in Love", "We Steal Secrets: The Story Of Wikileaks", "The Croods", "This Is the End", "The Frozen Ground", "Turbo", "Blackfish", "Frances Ha", "Prince Avalanche", "The Attack", "Grown Ups 2", "White House Down", "Lovelace", "Girl Most Likely", "Parkland", "Passion", "Monsters University", "R.I.P.D.", "Byzantium", "The Conjuring", "The Internship"];
    }

    function get_prices(){
        var filter = {
            currencies_pk : $scope.employer.currencies_pk
        }

        // var promise = EmployersFactory.prices(filter);
        // promise.then(function(data){
        //     var a = data.data.result;
            
        //     for(var i in a){
        //         $scope.prices[a[i].type] = parseFloat(a[i].price);
        //     }
        // })
    }

    function get_employer_bucket(){
        var filter = {
            pin : $scope.employer.pin
        }

        // var promise = EmployersFactory.employer_bucket(filter);
        // promise.then(function(data){
        //     var a = data.data.result;

        //     for(var i in a){
        //         $scope.employer_bucket.push(a[i].applicant_id)    
        //     }
        // })
    }

	function job_posts(){
        var filter = {
            pin : PINService.get(),
            archived : false
        };

        var promise = JobPostsFactory.fetch(filter);
        promise.then(function(data){
            var a = data.data.result;
            for(var i in a){
                var details = JSON.parse(a[i].details);
                $scope.job_posts.data.push({
                                                image : '../ASSETS/Uploads/employers/accenture3.png',
                                                title : details.title,
                                                time_passed : '1 week ago',
                                                experience : details.years_experience,
                                                skills : details.required_skills,
                                                ad : {
                                                    link : 'https://www.youtube.com/embed/n9EgH-QxaUI',
                                                    type : 'youtube'
                                                }
                                            });
            }
        })
        .then(null, function(data){
            
        });
    }

    $scope.navigate_ads = function(type){
        for(var i in $scope.newad){
            $scope.newad[i] = false;
        }

        $scope.newad[type] = true;
    }

    $scope.post_job = function(i){
        var post = {};

        if(i == 1){
            post.type = 'ads';
            post.details = JSON.stringify($scope.new_job_post.ad);
        }
        else if(i == 2){
            post.type = 'video';
            post.details = JSON.stringify($scope.new_job_post.video);
        }
        else if(i == 3){
            post.type = 'job';
            post.details = JSON.stringify($scope.new_job_post.job);
        }

        post.pin = PINService.get();

        var promise = JobPostsFactory.post_job(post);
        promise.then(function(data){
            job_posts();
        })
        .then(null, function(data){
            //failed to save
        });
    };

    $scope.uploadPic = function(file) {
        console.log(file);
        Upload.upload({
            url: "./functions/employers/upload.php",
            data: {file: file}
        }).then(function (resp) {
            $scope.cv = resp.data.file;
            $scope.picFile.result = true;
        }, function (resp) {
            $scope.errorMsg = true;
            //console.log('Error status: ' + resp.status);
        }, function (evt) {
            var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
            //console.log('progress: ' + progressPercentage + '% ');
        });

    }

    var currentDate = new Date();
    var postDate = currentDate;
    
    postDate.setMonth(postDate.getMonth() + 1);

    $scope.currentDate = currentDate.getFullYear() + "-" + zerofy(currentDate.getMonth()) + "-" + zerofy(currentDate.getDate());
    $scope.postDate = postDate.getFullYear() + "-" + zerofy(postDate.getMonth()+1) + "-" + zerofy(postDate.getDate());

    function zerofy(num) {
        var str = num.toString();
        if (num>=1 && num<=9) {
            str = "0" + str;
        }

        return str;
    }
    
});