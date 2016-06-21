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
            },
            fee : {
                currency : 'PHP',
                amount : '5,000.00'
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
            },
            fee : {
                currency : 'PHP',
                amount : '500.00'
            }
        }
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

        reload_feeds();
    }
    
    function reload_feeds(){
        var job_titles = [
            'Game Developer',
            'Customer Service Representative',
            'Technical Support Representative',
            'Web Designer'
        ];

        var logos = [
            '../ASSETS/Uploads/employers/accenture3.png',
            '../ASSETS/Uploads/employers/ibex2.png',
            '../ASSETS/Uploads/employers/uhg2.jpeg'
        ];

        var skills = [
            'Skills Required: Maya, 3D SMAX',
            'Skills Required: Good Communication Skills',
            'Skills Required: Excellent Communication Skills, Basic Troubleshooting',
            'Skills Required: CSS3, HTML5'
        ];

        var years = [
            '5 years related work experience',
            '4 years related work experience',
            '3 years related work experience',
            '2 years related work experience',
            '1 years related work experience'
        ];

        var fee = [
            '1,000.00',
            '2,000.00',
            '3,000.00',
            '4,000.00',
            '5,000.00'
        ];

        var timer = [
            10000,
            5000,
            7000
        ];

        $scope.feeds.data.unshift({
            image : logos[[Math.floor(Math.random() * logos.length)]],
            title : job_titles[[Math.floor(Math.random() * job_titles.length)]],
            time_passed : 'Just now',
            experience : years[[Math.floor(Math.random() * logos.length)]],
            skills : skills[[Math.floor(Math.random() * logos.length)]],
            fee : {
                currency : 'PHP',
                amount : fee[[Math.floor(Math.random() * logos.length)]]
            }
        });

        var to = $timeout(function() {
            $timeout.cancel(to);
            
            reload_feeds();

        }, timer[[Math.floor(Math.random() * timer.length)]]);
    }

    $scope.pitch_focus = function(){
        if($scope.pitch == "Make a pitch!"){
            $scope.pitch = "";
        }
    }
});