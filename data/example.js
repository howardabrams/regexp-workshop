/* See https://github.com/howardabrams/labrats for code details,
 * and complete documentation and comments.
 */

(function( $ ){

   /**
    * Calls a function based on an assigned test group for a user.
    */

   $.labrats = function(params) {
     // Save off the original numgroups setting...
     var origNumGroups = $.labrats.settings.groups;

     if (typeof params === 'object') {
       // The number of groups should be the number of callbacks
       $.labrats.settings.groups = params.callbacks.length;

       // Use the new numGroup setting:
       var groupnum = $.labrats.group(params);

       $.labrats.settings.groups = origNumGroups;

       var id = params.key;
       if (! id) {
         id = $.labrats.getId();
       }

       if (groupnum == -1) {    // User is part of the control group
         return params.control.apply(this, [id, groupnum]);
       }
       else {
         return params.callbacks[groupnum].apply(this, [id, groupnum]);
       }
     }
     else {
       var keys  = [];
       var funcs = [];

       for (var i = 0; i < arguments.length; i++) {
         if (typeof arguments[i] === 'function') {
           funcs.push (arguments[i]);
         }
         else {
           keys.push (arguments[i]);
         }
       }

       // The number of groups should be the number of callbacks
       $.labrats.settings.groups = funcs.length;

       var groupnum = $.labrats.group(keys);

       $.labrats.settings.groups = origNumGroups;

       if (funcs[groupnum]) {
         return funcs[groupnum].apply(this, [keys[0], groupnum]);
       }
       else {
         throw("No callback function given for group number: "+groupnum);
       }
     }
   };

   /**
    * Behaves like the utility function, `$.labrats()`.
    */

   $.fn.labrats = function(params) {
     return $.labrats.apply(this, [params]);
   };

   /* Slicing Test Pool */

   $.labrats.group = function(params) {
     if (! params) {
       params = {};
     }

     var key, controlValue,
         groups = $.labrats.settings.groups,
         slices, slice, subset = 100,
         keyValue,
         hash = params.hash || $.labrats.settings.hash;

     if ($.isArray(params)) {
       key = $.labrats.key(params);
       keyValue = parseInt(hash(key));
     }
     else if (typeof params === 'object') {
       if (params.key) {
         key = params.key + params.name;
       }
       else {
         key = $.labrats.getId() + params.name;
       }
       keyValue = parseInt(hash(key));
       groups = params.groups || groups;

       if (params.slices != null && params.slice != null) {
         slices = params.slices;
         slice  = params.slice;
       }
       if (params.subset) {
         subset = params.subset;
         controlValue = keyValue % 100;
       }
     }
     else {
       key = $.labrats.key(arguments);
       keyValue = parseInt(hash(key));
     }

     if (!key) {
       // Still no key? Use random number stored in cookie
       key = $.labrats.getId();
     }

     if (controlValue && controlValue > subset) {
       return -1;  // In the control group...
     }

     if ( (slices && keyValue % slices == slice) || !slices) {
       return keyValue % groups;
     }
     else {
       return -1;   // Aren't part of the slice, then user is
     }              // part of the control group.
   };

   /**
    * A test to see if a particular 'key' is part of the given group.
    * Returns `true` if a given key is in the group number, `false`
    * otherwise.
    */

   $.labrats.inGroup = function(groupnum, opts) {
     if (typeof opts === 'object') {
       return $.labrats.group(opts) === groupnum;
     }
     else {
       var args = Array.prototype.slice.call(arguments);
       var groupnum = args.shift();
       return $.labrats.group(args) == groupnum;
     }
   };

   /**
    * Converts a series of arguments into a *key* to use in a
    * hash. Each function may call this using a few formats.
    */

   $.labrats.key = function(a) {
     var params;
     if ($.isArray(a)) {
       params = a;
     }
     else if (typeof a === 'object') {
       params = arguments[0];
     }
     else {
       params = arguments;
     }

     var key = params[0];
     for (var i = 1; i < params.length; i++) {
       if (params[i]) {
         switch (typeof params[i]) {
           case "string":
             key += params[i];
             break;
           case "function":
             break;
           default:
             key += params[i].toString();
         }
       }
     }
     return key;
   };

   /**
    * Sets a particular cookie with a given key and value. Both values
    * will be escaped.
    */

   function setCookie(key,value) {
     document.cookie = escape(key) + "=" + escape(value);
   }

   /**
    * Simple function for retrieving a particular cookie by its key.
    * If the cookie has not be set, then this returns null.
    */

   function getCookie(key) {
     return unescape(document.cookie.replace(new RegExp("(?:(?:^|.*;\\s*)" +
                                                        escape(key).replace(/[\-\.\+\*]/g, "\\$&") +
                                                        "\\s*\\=\\s*((?:[^;](?!;))*[^;]?).*)|.*"), "$1")) || null;
   }

   /**
    * Returns an unique identification for the current user's browser.
    * If this is the first time a user has seen the application, we
    * generate a new ID (as a random number), otherwise, we return the
    * ID stored in a cookie.
    */

   $.labrats.getId = function() {
     var label = 'labrats_userID',
            id = getCookie(label);
     if (id == null) {
       id = Math.floor( Math.random() * 100000000 ).toString();
       setCookie(label, id);
     }
     return id;
   };

   /**
    * Configuration settings begins with 'default values'. However,
    * the 'configure()' function can be called with a map of key/value
    * pairs to override any of these settings.
    */

   $.labrats.settings = {

     // This hash function is pretty stupid, and should NOT be used.
     // However, if you are just playing around with this project... fine.
     hash: function(key) {
       var results = 0;
       for(c in key) {
         results += key.charCodeAt(c);
       }
       // console.log("Key:", key, "Hash:", results);
       return Math.abs(results);
     }
   };

   /**
    * This function allows a single object to overwrite some, but not
    * all configuration values. Acceptable values include:
    *
    *  - `hash`: A function used to convert a user ID key and test name into a number
    *  - `groups`: The number of test groups to divide the user pool
    */

   $.labrats.configure = function(config) {
     for (var key in config) {
       if (config.hasOwnProperty(key)) {
         $.labrats.settings[key] = config[key];
       }
     }
   };

 })( jQuery );
