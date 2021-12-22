var QB64 = new function() {

    this.initArray = function(a, size, obj) {
        for (var i=0; i <= size; i++) {
            a.push(JSON.parse(JSON.stringify(obj)));
        }
    };

    this.func__Round = function(value) {
        return Math.round(value);
    };

    this.sub__Title = function(title) {
        document.title = title;
    };

    this.func__Trim = function(value) {
        return value.trim();
    };


    this.func_Chr = function(charCode) {
        return String.fromCharCode(charCode);
    };

    this.func_Left = function(value, n) {
        return String(value).substring(0, n);
    };

    this.func_Str = function(value) {
        return String(value);
    };

    this.func_UBound = function(a) {
        return a.length-1;
    };

    this.func_UCase = function(value) {
        return String(value).toUpperCase();
    };
}