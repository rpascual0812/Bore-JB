app.controller('Feeds', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory,
                                    JobPostsFactory,
                                    RegisterFactory,
                                    $timeout,
                                    $window,
                                    PINService
								){

    $scope.apppin = md5.createHash('APPPIN');
    $scope.pitch = 'Make a pitch!';

	$scope.profile = {};

    $scope.feeds = {};
    $scope.feeds.ad = {};
    $scope.hide = 'ng-hide';

        
    $scope.feeds.data = [];
    $scope.confirmed='';

    $scope.profile_form = {}
    $scope.profile_form.personal = {};
    $scope.profile_form.achievements = {};
    $scope.profile_form.education = {};
    $scope.profile_form.work= {};
    $scope.today = new Date();

    $scope.view={};
    
    $scope.view.personal_info='ng-hide';
    $scope.view.education='ng-hide';
    $scope.view.achievements='ng-hide';
    $scope.view.work='ng-hide';
    

    
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
            },
            fee : {
                currency : 'PHP',
                amount : '1,000.00'
            },
            background : '../ASSETS/Uploads/employers/backgrounds/12.png'
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
            },
            fee : {
                currency : 'PHP',
                amount : '5,000.00'
            },
            background : '../ASSETS/Uploads/employers/backgrounds/11.png'
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
            },
            fee : {
                currency : 'PHP',
                amount : '500.00'
            },
            background : '../ASSETS/Uploads/employers/backgrounds/10.png'
        }
    ];
    $scope.job_titles = [
        'Game Developer',
        'Customer Service Representative',
        'Technical Support Representative',
        'Web Designer',
        'CSR - Media & Publishing',
        'Bank Compliance Officer',
        'Nurse Practitioner Representative',
        'Business Development Managers',
        'USRN Clinical Analyst',
        'AX Functional Consultant',
        'Functional Consultant'
    ];

    $scope.logos = [
        '../ASSETS/Uploads/employers/accenture3.png',
        '../ASSETS/Uploads/employers/ibex2.png',
        '../ASSETS/Uploads/employers/uhg2.jpeg',
        '../ASSETS/Uploads/employers/CSSCORP.png',
        '../ASSETS/Uploads/employers/exl.jpg',
        '../ASSETS/Uploads/employers/inner-works-logo-thumb.jpg',
        '../ASSETS/Uploads/employers/logo.jpg',
        '../ASSETS/Uploads/employers/logo_8773_banner_0_9226.jpeg',
        '../ASSETS/Uploads/employers/perks_17.png',
        '../ASSETS/Uploads/employers/teleperformance-philippines.png'
    ];

    $scope.skills = [
        'Skills Required: Maya, 3D SMAX',
        'Skills Required: Good Communication Skills',
        'Skills Required: Excellent Communication Skills, Basic Troubleshooting',
        'Skills Required: CSS3, HTML5'
    ];

    $scope.years = [
        '5 years related work experience',
        '4 years related work experience',
        '3 years related work experience',
        '2 years related work experience',
        '1 years related work experience'
    ];

    $scope.fee = [
        '1,000.00',
        '2,000.00',
        '3,000.00',
        '4,000.00',
        '5,000.00'
    ];

    $scope.background = [
        '../ASSETS/Uploads/employers/backgrounds/1.png',
        '../ASSETS/Uploads/employers/backgrounds/2.png',
        '../ASSETS/Uploads/employers/backgrounds/3.png',
        '../ASSETS/Uploads/employers/backgrounds/4.png',
        '../ASSETS/Uploads/employers/backgrounds/5.png',
        '../ASSETS/Uploads/employers/backgrounds/6.png',
        '../ASSETS/Uploads/employers/backgrounds/7.png',
        '../ASSETS/Uploads/employers/backgrounds/8.png',
        '../ASSETS/Uploads/employers/backgrounds/9.png',
        '../ASSETS/Uploads/employers/backgrounds/10.png',
        '../ASSETS/Uploads/employers/backgrounds/11.png',
        '../ASSETS/Uploads/employers/backgrounds/12.png'
    ];

    $scope.timer = [
        10000,
        5000,
        7000
    ];
    
    init();

    function init(){ 
        var result = checkpin();
        if(result == false){
            window.location = "#/login";
        }
        else {
            // $scope.profile.pin = result;

            // var pin = $cookies.get($scope.apppin);
            
            // var filter = {
            //     applicant_id : pin
            // }

            // var promise = ProfileFactory.profile(filter);
            // promise.then(function(data){
            //     $scope.profile.status = true;
            //     $scope.profile.data = data.data.result[0];

            //     $scope.profile.data.currency = 'PHP';
            //     $scope.profile.data.available = '0.00';
            // })
            // .then(null, function(data){
            //     $scope.profile.status = false;
            // });
            get_profile();

        }
    }

    function checkpin(){
        var pin = PINService.get();
        return pin;
    }

    function get_profile(){
        var filter = {
            pin : PINService.get()
        };
        var promise = ProfileFactory.profile(filter);
        promise.then(function(data){
            $scope.profile = data.data.result[0];
            $scope.profile.profile = JSON.parse($scope.profile.profile);
         //   console.log($scope.profile.profile);
            //if($scope.profile.suspended == false){
                reload_ads();
                reload_feeds();
                check();

            //}            
            
        });
    }


    function reload_ads(){
        $scope.feeds.ad.image = $scope.logos[[Math.floor(Math.random() * $scope.logos.length)]];
        $scope.feeds.ad.title = $scope.job_titles[[Math.floor(Math.random() * $scope.job_titles.length)]];
        $scope.feeds.ad.time_passed = 'Just now';
        $scope.feeds.ad.experience = $scope.years[[Math.floor(Math.random() * $scope.years.length)]];
        $scope.feeds.ad.skills = $scope.skills[[Math.floor(Math.random() * $scope.skills.length)]];
        $scope.feeds.ad.fee = {
            currency : 'PHP',
            amount : $scope.fee[[Math.floor(Math.random() * $scope.fee.length)]]
        }
        $scope.feeds.ad.background = $scope.background[[Math.floor(Math.random() * $scope.skills.length)]];

        var to1 = $timeout(function() {
            $timeout.cancel(to1);
            
            reload_ads();

        }, 20000);
    }
    
    function reload_feeds(){
        var filter = {
            pin : PINService.get()
        };
        var promise = JobPostsFactory.feeds(filter);
        promise.then(function(data){
            var a = data.data.result;
            for(var i in a){
                a[i].details = JSON.parse(a[i].details);
                
                $scope.feeds.data.push(
                    {
                        image : $scope.logos[[Math.floor(Math.random() * $scope.logos.length)]],
                        title : a[i].details.title,
                        time_passed : 'Just now',
                        experience : a[i].details.years_experience,
                        skills : a[i].details.required_skills,
                        fee : {
                            currency : 'PHP',
                            amount : $scope.fee[[Math.floor(Math.random() * $scope.fee.length)]]
                        },
                        background : $scope.background[[Math.floor(Math.random() * $scope.skills.length)]]
                    }
                );
            }

            //console.log($scope.feeds);
        })

        // $scope.feeds.data.unshift({
        //     image : $scope.logos[[Math.floor(Math.random() * $scope.logos.length)]],
        //     title : $scope.job_titles[[Math.floor(Math.random() * $scope.job_titles.length)]],
        //     time_passed : 'Just now',
        //     experience : $scope.years[[Math.floor(Math.random() * $scope.years.length)]],
        //     skills : $scope.skills[[Math.floor(Math.random() * $scope.skills.length)]],
        //     fee : {
        //         currency : 'PHP',
        //         amount : $scope.fee[[Math.floor(Math.random() * $scope.fee.length)]]
        //     },
        //     background : $scope.background[[Math.floor(Math.random() * $scope.skills.length)]]
        // });

        // var to2 = $timeout(function() {
        //     $timeout.cancel(to2);
            
        //     reload_feeds();
        // }, $scope.timer[[Math.floor(Math.random() * $scope.timer.length)]]);
    }

    $scope.pitch_focus = function(){
        if($scope.pitch == "Make a pitch!"){
            $scope.pitch = "";
        }
    }


    $scope.show =function(status){
        if(status==true){
            $scope.confirmed= false;
            return true;
        }

    } 
    
    $scope.searchbig = function(){

        console.log($scope.hide);
        $scope.hide = 'ng-show';

    }


        $scope.update = function(word){


            console.log($scope.today);

            var form = {};
            if(word === 'personal_info'){
                form.info = JSON.stringify($scope.profile_form.personal);
                form.type = word;
                $scope.view.personal_info = 'ng-hide';
                $scope.view.achievements = 'show';
                $scope.view.education = 'ng-hide';
                $scope.view.work = 'ng-hide';

            }else if(word === 'achievements'){
                form.info = JSON.stringify($scope.profile_form.achievements);
                form.type = word;
                $scope.view.achievements = 'ng-hide';
                $scope.view.education = 'ng-show';
                $scope.view.work = 'ng-hide';
            }
            else if(word === 'education'){
                form.info = JSON.stringify($scope.profile_form.education);
                form.type = word;
                $scope.view.education = 'ng-hide';
                $scope.view.work = 'ng-show';
            }else if(word === 'work'){
                form.info = JSON.stringify($scope.profile_form.work);
                form.type = word;
                $scope.view.work = 'ng-hide';
            }
            form.pin = PINService.get();
            var promise =ProfileFactory.update(form);
            promise.then(function(data){

                console.log(' Successful Update');
            })
            .then(null, function(data){ 
                console.log('Failed Update');
            });
        };

        var left = screen.width / 2 - 200, top = screen.height / 2 - 250
        $scope.facebook = function(){
            console.log('fb');
            $window.open('http://www.facebook.com/sharer.php?u=https://joberfied.com' , '_blank' , "top=" + top + ",left=" + left + ",width=400,height=500")
        };
        $scope.twitter = function(){
            $window.open('https://twitter.com/share?url=https://joberfied.com&amp;hashtags=joberfied!!' , '_blank' , "top=" + top + ",left=" + left + ",width=400,height=500")
        };
        $scope.google = function(){
            $window.open('https://plus.google.com/share?url=https://joberfied.com' , '_blank' , "top=" + top + ",left=" + left + ",width=400,height=500")
        };
        $scope.linkedin = function(){
            $window.open('http://www.linkedin.com/shareArticle?mini=true&amp;url=https://joberfied.com' , '_blank' , "top=" + top + ",left=" + left + ",width=400,height=500")
        };
        $scope.email = function(){
            $window.open('mailto:?Subject=JOBERFIED&amp;Body=I%20saw%20this%20and%20thought%20of%20you!%20 https://joberfied.com' , '_blank' , "top=" + top + ",left=" + left + ",width=400,height=500")
        };

        $scope.check = function(){
            check();
        }

        function check(){
            if(!$scope.profile.profile.hasOwnProperty('personal_info')){
                $scope.view.personal_info='ng-show';
                console.log("personal_info");
            }else if(!$scope.profile.profile.hasOwnProperty('achievements')){
                $scope.view.achievements='ng-show';
                console.log("achievements");
            }else if(!$scope.profile.profile.hasOwnProperty('education')){
                $scope.view.education='ng-show';
                console.log("education");
            }else if(!$scope.profile.profile.hasOwnProperty('work')){
                $scope.view.work='ng-show';
                console.log("WORK");
            }else{
                $scope.view.personal_info='ng-hide';
                $scope.view.education='ng-hide';
                $scope.view.achievements='ng-hide';
                $scope.view.work='ng-hide';

            }
        }

});