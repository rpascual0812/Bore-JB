app.service('SearchService', function ($cookies) {
    var text = null;

    return {
        get: function(){
            var cookie = $cookies.get('search_text');  

            if(cookie === undefined){
                text = null
            }
            else {
                text = cookie;
            }

            return text;
        },
        set: function(search_text){
            var now = new Date()
            var exp = new Date(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours() + 1);

            $cookies.put('search_text', search_text, { expires : exp });
        }
    };
});