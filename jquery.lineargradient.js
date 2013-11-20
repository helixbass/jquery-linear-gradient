(function() {
  var Color, Tween, extend, type, _init, _int, _parse, _prop, _prop_val, _unit;

  extend = $.extend, Tween = $.Tween, type = $.type, Color = $.Color;

  _prop = 'backgroundImage';

  _unit = '%';

  _int = function(str) {
    return parseInt(str, 10);
  };

  _init = function(tween) {
    var elem, end;

    elem = tween.elem, end = tween.end;
    return extend(tween, {
      start: _parse($(elem).css(_prop)),
      end: _parse(end),
      set: true
    });
  };

  _parse = function(val) {
    var all, angle, stops, _ref, _stops;

    _ref = /linear-gradient\(\s*(\d+)deg[,]+((?:(?:rgb\([^)]*\))|[^)]+)*)\)\s*$/.exec(val), all = _ref[0], angle = _ref[1], _stops = _ref[2];
    stops = (function() {
      var stop, _i, _len, _match, _ref1, _results;

      _ref1 = _stops.split(/%,\s*/);
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        stop = _ref1[_i];
        _match = /^\s*((?:rgb\([^)]*\))|(?:\#[0-9A-Fa-f]+)|\w+)\s+([0-9.]+)/.exec(stop);
        _results.push({
          color: Color(_match[1]),
          pos: _int(_match[2])
        });
      }
      return _results;
    })();
    return {
      angle: _int(angle),
      stops: stops
    };
  };

  _prop_val = function(tween) {
    var end, i, pos, start, stop, _scaled, _stops;

    pos = tween.pos, start = tween.start, end = tween.end;
    _scaled = function(_prop) {
      return _prop(start) + pos * (_prop(end) - _prop(start));
    };
    _stops = (function() {
      var _i, _len, _ref, _results;

      _ref = start.stops;
      _results = [];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        stop = _ref[i];
        _results.push({
          color: stop.color.transition(end.stops[i].color, pos),
          pos: _scaled(function(val) {
            return val.stops[i].pos;
          })
        });
      }
      return _results;
    })();
    return "linear-gradient( " + (_scaled(function(val) {
      return val.angle;
    })) + "deg, " + (((function() {
      var _i, _len, _results;

      _results = [];
      for (_i = 0, _len = _stops.length; _i < _len; _i++) {
        stop = _stops[_i];
        _results.push("" + stop.color + " " + stop.pos + _unit);
      }
      return _results;
    })()).join(', ')) + " )";
  };

  extend(Tween.propHooks, {
    linearGradient: {
      get: function(tween) {
        return _parse($(tween.elem).css(_prop));
      },
      set: function(tween) {
        if (!tween.set) {
          _init(tween);
        }
        return $(tween.elem).css(_prop, _prop_val(tween));
      }
    }
  });

}).call(this);
