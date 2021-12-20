var QB64 = new function() {

    this.initArray = function(a, size, obj) {
        for (var i=0; i <= size; i++) {
            a.push(JSON.parse(JSON.stringify(obj)));
        }
    }

    
    this.sub__Title = function(title) {
        document.title = title;
    }

    this.func_Chr = function(charCode) {
        return String.fromCharCode(charCode);
    }

    this.func_UBound = function(a) {
        return a.length-1;
    }
}