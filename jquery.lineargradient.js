(function() {
  var Color, Tween, extend, radial_prop_val, type, _init, _int, _parse, _parse_radial, _prop, _prop_val, _top_level_args;

  extend = $.extend, Tween = $.Tween, type = $.type, Color = $.Color;

  _prop = 'backgroundImage';

  _int = function(str) {
    return parseInt(str, 10);
  };

  _top_level_args = function(val) {
    return val.match(/[^\(,]*\((?:[^\(\)]+|[^\(\)]+\([^\)]+\)[^\(\)]*)+\)[^,]*|[^,]+/g);
  };

  _init = function(tween, radial) {
    var elem, end;
    if (radial == null) {
      radial = false;
    }
    elem = tween.elem, end = tween.end;
    return extend(tween, {
      start: _parse($(elem).css(_prop), radial),
      end: _parse(end, radial),
      set: true,
      unit: -1 < end.indexOf('%') ? '%' : 'px'
    });
  };

  _parse_radial = function(val) {
    return _parse(val, {
      func_prefix: 'radial',
      angle_pos_re: '([^,]+)'
    });
  };

  _parse = function(val, opts) {
    var image, _i, _len, _ref, _results;
    extend(opts, {
      func_prefix: 'linear',
      angle_pos_re: '(-?\d+)deg'
    });
    _ref = _top_level_args(val);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      image = _ref[_i];
      _results.push((function() {
        var all, angle_or_pos, stops, _match, _stops;
        _match = RegExp("" + func_prefix + "-gradient\\(\\s*" + angle_pos_re + "[,]+((?:(?:rgb\\([^)]*\\))|[^)]+)*)\\)\\s*$").exec(image);
        if (!_match) {
          return image;
        }
        all = _match[0], angle_or_pos = _match[1], _stops = _match[2];
        stops = (function() {
          var stop, _j, _len1, _ref1, _ref2, _results1;
          _ref1 = _top_level_args(_stops);
          _results1 = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            stop = _ref1[_j];
            _match = /^\s*((?:rgb\([^)]*\))|(?:\#[0-9A-Fa-f]+)|\w+)(?:\s+([0-9.]+)(%|\w+))?/.exec(stop);
            _results1.push({
              color: Color(_match[1]),
              pos: _int((_ref2 = _match[2]) != null ? _ref2 : 0)
            });
          }
          return _results1;
        })();
        return {
          angle_or_pos: _int(angle_or_pos),
          stops: stops
        };
      })());
    }
    return _results;
  };

  _prop_val = function(tween, func) {
    var end, image, imageIndex, pos, start, unit;
    if (func == null) {
      func = 'linear-gradient';
    }
    pos = tween.pos, unit = tween.unit, start = tween.start, end = tween.end;
    return ((function() {
      var _i, _len, _results;
      _results = [];
      for (imageIndex = _i = 0, _len = start.length; _i < _len; imageIndex = ++_i) {
        image = start[imageIndex];
        _results.push((function() {
          var i, stop, _scaled, _stops;
          if ('string' === type(image)) {
            return image;
          }
          _scaled = function(_prop) {
            return _prop(image) + pos * (_prop(end[imageIndex]) - _prop(image));
          };
          _stops = (function() {
            var _j, _len1, _ref, _results1;
            _ref = image.stops;
            _results1 = [];
            for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
              stop = _ref[i];
              _results1.push({
                color: stop.color.transition(end[imageIndex].stops[i].color, pos),
                pos: _scaled(function(val) {
                  return val.stops[i].pos;
                })
              });
            }
            return _results1;
          })();
          return "" + func + "( " + (_scaled(function(val) {
            return val.angle_or_pos;
          })) + "deg, " + (((function() {
            var _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = _stops.length; _j < _len1; _j++) {
              stop = _stops[_j];
              _results1.push("" + stop.color + " " + stop.pos + unit);
            }
            return _results1;
          })()).join(', ')) + " )";
        })());
      }
      return _results;
    })()).join(', ');
  };

  radial_prop_val = function(tween) {
    return _prop_val(tween, 'radial-gradient');
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
    },
    radialGradient: {
      get: function(tween) {
        return _parse($(tween.elem).css(_prop), true);
      },
      set: function(tween) {
        if (!tween.set) {
          _init(tween, true);
        }
        return $(tween.elem).css(_prop, radial_prop_val(tween));
      }
    }
  });

}).call(this);
