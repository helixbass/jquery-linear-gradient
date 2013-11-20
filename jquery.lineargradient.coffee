{ extend, Tween, type, Color } = $

_prop = 'backgroundImage'
_unit = '%'

_int = ( str ) ->
  parseInt str, 10

_init = ( tween ) ->
  { elem, end } = tween

  extend tween,
   start: _parse $( elem ).css _prop
   end: _parse end
   set: yes

_parse = ( val ) ->
  [ all, angle, _stops ] =
   ///
    linear-gradient\(
    \s *
    (
     \d +
    )
    deg
    [, ] +
    (
     (?:
      (?:
       rgb\(
        [^)] *
       \)
      )
       |
      [^)] +
     ) *
    )
    \)
    \s *
    $
   ///.exec val
  stops = do ->
    for stop in _stops.split /%,\s*/
        _match =
         ///
          ^
          \s *
          (
           (?:
            rgb\(
             [^)] *
            \)
           )
            |
           (?:
            \#
            [0-9A-Fa-f] +
           )
            |
           \w +
          )
          \s +
          (
           [0-9.] +
          )
         ///.exec stop
        color:
         Color _match[ 1 ]
        pos:
         _int _match[ 2 ]
  angle:
   _int angle
  stops:
   stops

_prop_val = ( tween ) ->
  { pos,
    start,
    end } = tween
  _scaled = ( _prop ) ->
    # _prop = if 'string' is type prop
    #             ( val ) -> val[ prop ]
    #         else
    #             prop
    _prop( start ) + pos * ( _prop( end ) - _prop( start ))

  _stops = ( { color:
                stop.color.transition end.stops[ i ].color, pos
               pos:
                _scaled ( val ) -> val.stops[ i ].pos } for stop, i in start.stops )
  "linear-gradient( #{ _scaled ( val ) -> val.angle }deg, #{ ( "#{ stop.color } #{ stop.pos }#{ _unit }" for stop in _stops ).join ', ' } )"

extend Tween.propHooks,
 linearGradient:
  get: ( tween ) ->
    _parse $( tween.elem ).css _prop
  set: ( tween ) ->
    _init tween unless tween.set

    $( tween.elem )
     .css _prop,
          _prop_val tween
