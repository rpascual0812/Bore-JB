app.service('PINService', function ($cookies, md5) {
    return {
        get: function(){
            var pin = $cookies.get(md5.createHash('PIN'));   
            
            if(pin === undefined){
                return false;
            }
            else {
                return pin;
            }
        }
    };
});