{ extend, Tween, type, Color } = $

_prop = 'backgroundImage'

_int = ( str ) ->
  parseInt str, 10

_top_level_args = ( val ) ->
    val.match ///
               [^\(,] *
               \(
               (?:
                [^\(\)] +
                 |
                [^\(\)] +
                \(
                 [^\)] +
                \)
                [^\(\)] *
               ) +
               \)
               [^,] *
                |
               [^,] +
              ///g

_init = ( tween, radial=no ) ->
  { elem, end } = tween

  extend tween,
    start: _parse $( elem ).css(_prop), radial
    end: _parse end, radial
    set: yes
    unit: if -1 < end.indexOf '%'
            '%'
          else
            'px'

_parse_radial = ( val ) ->
  _parse val,
    func_prefix:    'radial'
    angle_pos_re:   '([^,]+)'
_parse = ( val, opts ) ->
  extend opts,
    func_prefix:    'linear'
    angle_pos_re:   '(-?\d+)deg'
  for image in _top_level_args val
    do ->
      _match =
       ///
        #{ func_prefix }-gradient\(
        \s *
        #{ angle_pos_re }
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
       ///.exec image

      return image unless _match

      [ all, angle_or_pos, _stops ] = _match

      stops = do ->
        for stop in _top_level_args _stops
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
              (?:
               \s +
               (
                [0-9.] +
               )
               (
                %
                 |
                \w +
               )
              ) ?
             ///.exec stop
            color:
             Color _match[ 1 ]
            pos:
             _int( _match[ 2 ] ? 0 )
      angle_or_pos:
       _int angle_or_pos
      stops:
       stops

_prop_val = ( tween, func='linear-gradient' ) ->
  { pos,
    unit,
    start,
    end } = tween
  ( for image, imageIndex in start
        do ->
         return image if 'string' is type image

         _scaled = ( _prop ) ->
           # _prop = if 'string' is type prop
           #             ( val ) -> val[ prop ]
           #         else
           #             prop
           _prop( image ) + pos * ( _prop( end[ imageIndex ] ) - _prop( image ))

         _stops = ( { color:
                       stop.color.transition end[ imageIndex ].stops[ i ].color, pos
                      pos:
                       _scaled ( val ) -> val.stops[ i ].pos } for stop, i in image.stops )
         "#{ func }( #{ _scaled ( val ) -> val.angle_or_pos }deg, #{ ( "#{ stop.color } #{ stop.pos }#{ unit }" for stop in _stops ).join ', ' } )" )
   .join ', '
radial_prop_val = ( tween ) -> _prop_val tween, 'radial-gradient'

extend Tween.propHooks,
 linearGradient:
  get: ( tween ) ->
    _parse $( tween.elem ).css _prop
  set: ( tween ) ->
    _init tween unless tween.set

    $( tween.elem )
     .css _prop,
          _prop_val tween
 radialGradient:
  get: ( tween ) ->
    _parse $( tween.elem ).css(_prop), yes
  set: ( tween ) ->
    _init tween, yes unless tween.set

    $( tween.elem )
     .css _prop,
          radial_prop_val tween
