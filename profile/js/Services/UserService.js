app.service('UserService', function ($cookies, md5) {
    return {
        get: function(){
            var pin = $cookies.get(md5.createHash('APPPIN'));   
            
            if(pin === undefined){
                return false;
            }
            else {
                return pin;
            }
        }
    };
});