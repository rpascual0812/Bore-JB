app.controller('Feeds', function(
									$scope,
                                    md5,
                                    $cookies,
                                    $routeParams,
                                    ProfileFactory,
                                    $timeout,
                                    UserService
								){

    $scope.apppin = md5.createHash('APPPIN');
    $scope.pitch = 'Make a pitch!';

	$scope.profile = {};

    $scope.feeds = {};
    $scope.feeds.ad = {};
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
        $scope.profile.pin = UserService.get();

        var pin = $cookies.get(md5.createHash('APPPIN'));
        
        var filter = {
            applicant_id : pin
        }

        var promise = ProfileFactory.profile(filter);
        promise.then(function(data){
            $scope.profile.status = true;
            $scope.profile.data = data.data.result[0];

            $scope.profile.data.currency = 'PHP';
            $scope.profile.data.available = '0.00';
        })
        .then(null, function(data){
            $scope.profile.status = false;
        });

        reload_ads();
        reload_feeds();
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
        $scope.feeds.data.unshift({
            image : $scope.logos[[Math.floor(Math.random() * $scope.logos.length)]],
            title : $scope.job_titles[[Math.floor(Math.random() * $scope.job_titles.length)]],
            time_passed : 'Just now',
            experience : $scope.years[[Math.floor(Math.random() * $scope.years.length)]],
            skills : $scope.skills[[Math.floor(Math.random() * $scope.skills.length)]],
            fee : {
                currency : 'PHP',
                amount : $scope.fee[[Math.floor(Math.random() * $scope.fee.length)]]
            },
            background : $scope.background[[Math.floor(Math.random() * $scope.skills.length)]]
        });

        var to2 = $timeout(function() {
            $timeout.cancel(to2);
            
            reload_feeds();

        }, $scope.timer[[Math.floor(Math.random() * $scope.timer.length)]]);
    }

    $scope.pitch_focus = function(){
        if($scope.pitch == "Make a pitch!"){
            $scope.pitch = "";
        }
    }
});