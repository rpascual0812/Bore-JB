app.controller('Messages', function(
									$scope,
                                    md5,
                                    $cookies,
                                    CandidatesFactory,
                                    PINService,
                                    SearchService
								){

    $scope.Candidate = {};
    $scope.messages = {};

    $scope.messages.menu = {
        inbox : 'active',
        draft : '',
        sent : '',
        new_message : ''
    };

    $scope.messages.inbox = {};
    $scope.messages.inbox.status = false;

    $scope.messages.draft = {};
    $scope.messages.draft.status = false;

    $scope.messages.sent = {};
    $scope.messages.sent.status = false;

    $scope.messages.new_message = {};

    $scope.candidates = {};

    init();

    function init(){
        var result = checkpin();
    	if(result == false){
    		window.location = "#/login";
    	}
        else {
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
        }

        var promise = CandidatesFactory.fetch(filter);
        promise.then(function(data){
            $scope.Candidate = data.data.result[0];

            
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

    $scope.change_menu = function(menu){
        for(var i in $scope.messages.menu){
            $scope.messages.menu[i] = '';
        }

        $scope.messages.menu[menu] = 'active';
    }
});