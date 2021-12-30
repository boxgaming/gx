var QB64 = new function() {
    var _fgColor = null; 
    var _bgColor = null; 
    var _lastX = 0;
    var _lastY = 0;
    var _fntDefault = null;

    this.initArray = function(a, size, obj) {
        for (var i=0; i <= size; i++) {
            a.push(JSON.parse(JSON.stringify(obj)));
        }
    };

    this.func__FontHeight = function(fnt) {
        return GX.fontHeight(_fntDefault);
    };

    this.func__FontWidth = function(fnt) {
        return GX.fontWidth(_fntDefault);
    };

    this.func__Height = function(img) {
        // TODO: implement corresponding logic when an image handle is supplied
        return GX.sceneHeight();
    };

    this.func__KeyHit = function() {
        // TODO: actual implementation
        return 0;
    }

    this.sub__Limit = async function(fps) {
        // TODO: sleeeeep
        await _sleep(50);
    }

    function _sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    this.func__NewImage = function(iwidth, iheight) {
        return {
            width: iwidth,
            height: iheight
        };
    };

    this.sub__PrintString = function(x, y, s) {
        // TODO: check the background opacity mode
        // Draw the text background
        var ctx = GX.ctx();
        ctx.beginPath();
        ctx.fillStyle = _bgColor.rgba();
        ctx.fillRect(x, y, QB64.func__FontWidth(), QB64.func__FontHeight());
        GX.drawText(_fntDefault, x, y, s);
    };

    this.func__PrintWidth = function(s) {
        return String(s).length * QB64.func__FontWidth();
    };

    this.func__Pi = function(m) {
        if (m == undefined) {
            m = 1;
        }
        return Math.PI * m;
    }

    function _rgb(r, g, b) {
        return {
            r: r,
            g: g,
            b: b,
            a: 1,
            rgb: function() { return "rgb(" + this.r + "," + this.g + "," + this.b + ")"; },
            rgba: function() { return "rgba(" + this.r + "," + this.g + "," + this.b + "," + this.a + ")"; }
        }
    }

    this.func__RGB = function(r, g, b) {
        return this.func__RGB32(r, g, b);
    };

    this.func__RGB32 = function(r, g, b, a) {
        if (a == undefined) {
            a = 255;
        }
        if (b == undefined && g != undefined) {
            a = g;
            g = r;
            b = r;
        }
        else if (b == undefined) {
            g = r;
            b = r;
        }
        a = a / 255;

        return {
            r: r,
            g: g,
            b: b,
            a: a,
            rgb: function() { return "rgb(" + this.r + "," + this.g + "," + this.b + ")"; },
            rgba: function() { return "rgba(" + this.r + "," + this.g + "," + this.b + "," + this.a + ")"; }
        }
    }

    this.func__Round = function(value) {
        return Math.round(value);
    };

    this.sub__Title = function(title) {
        document.title = title;
    };

    this.func__Trim = function(value) {
        return value.trim();
    };

    this.func__Width = function(img) {
        // TODO: implement corresponding logic when an image handle is supplied
        return GX.sceneWidth();
    };



    this.func_Abs = function(value) {
        return Math.abs(value);
    };

    this.func_Chr = function(charCode) {
        return String.fromCharCode(charCode);
    };

    this.sub_Color = function(fg, bg) {
        if (fg != undefined) {
            _fgColor = fg;
        }
        if (bg != undefined) {
            _bgColor = bg;
        }
    };

    this.func_Cos = function(value) {
        return Math.cos(value);
    };

    this.func_Left = function(value, n) {
        return String(value).substring(0, n);
    };

    this.func_Len = function(value) {
        return String(value).length;
    };

    this.sub_Line = function(sstep, sx, sy, estep, ex, ey, color, style, pattern) {
        if (color == undefined) {
            if (style == "BF") {
                color = _bgColor;
            }
            else {
                color = _fgColor;
            }
        }
        if (sstep) {
            sx = _lastX + sx;
            sy = _lastY + sy;
        }
        if (sx == undefined) {
            sx = _lastX;
            sy = _lastY;
        }
        _lastX = sx;
        _lastY = sy;

        if (estep) {
            ex = _lastX + ex;
            ey = _lastY + ey;
        }
        _lastX = ex;
        _lastY = ey;

        var ctx = GX.ctx();
        //ctx.globalAlpha = color.a;

        if (style == "B") {
            ctx.strokeStyle = color.rgba();
            //ctx.strokeStyle = color;
            ctx.beginPath();
            ctx.strokeRect(sx, sy, ex-sx, ey-sy)
        } 
        else if (style == "BF") {
            ctx.fillStyle = color.rgba();
            //ctx.globalCompositeOperation = "source-over";
            ctx.beginPath();
            ctx.fillRect(sx, sy, ex-sx, ey-sy)
        } 
        else {
            ctx.strokeStyle = color.rgba();
            //ctx.globalCompositeOperation = "source-over";
            ctx.beginPath();
            ctx.moveTo(sx, sy);
            ctx.lineTo(ex, ey);
            ctx.stroke();
        }

        //ctx.globalAlpha = 1;
    };

    this.func_Mid = function(value, n, len) {
        return String(value).substring(n-1, n+len-1);
    };

    this.func_Right = function(value, n) {
        var s = String(value);
        return s.substring(s.length-n, s.length);
    };

    this.func_Rnd = function(n) {
        // TODO: implement modifier parameter
        return Math.random();
    }

    this.sub_Screen = function(mode) {
        if (mode < 2 || mode == 7 || mode == 13) {
            GX.sceneCreate(320, 200);
        }
        else if (mode == 8) {
            GX.sceneCreate(640, 200);
        }
        else if (mode == 9 || mode == 10) {
            GX.sceneCreate(640, 350);
        }
        else if (mode == 11 || mode == 12) {
            GX.sceneCreate(640, 480);
        }
        else if (mode.width != undefined) {
            GX.sceneCreate(mode.width, mode.height);
        }

        // initialize the graphics
        _fgColor = this.func__RGB(255, 255, 255); 
        _bgColor = this.func__RGB(0, 0, 0);

        // initialize the fonts
        if (!_fntDefault) {
            _fntDefault = GX.fontCreate("./qb64/font.png", 8, 14,
                "`1234567890-=~!@#$%^&*()_+\n" + 
                "qwertyuiop[]\\QWERTYUIOP{}|\n" + 
                "asdfghjkl;'ASDFGHJKL:\"\n" + 
                "zxcvbnm,./ZXCVBNM<>?");    
        }
    };

    this.func_Sin = function(value) {
        return Math.sin(value);
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