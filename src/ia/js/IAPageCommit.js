(function(env) {


    // placeholder

    DDH.IAPageCommit = function(ops) {
        this.init(ops); 
    };

    // this could get the single IA json like the index.
    // but for now the page is being built with xslate
    DDH.IAPageCommit.prototype = {
        init: function(ops) {
            console.log("IAPageCommit.init()\n"); 

            if (DDH_iaid) {
                console.log("for ia id '%s'", DDH_iaid);

                $.getJSON("/ia/commit/" + DDH_iaid + "/json", function(x) {
                    var iapc = Handlebars.templates.commit_page(x);
                    $("#ia_commit").html(iapc);
                });
            }
        }
    };

})(DDH);
 
