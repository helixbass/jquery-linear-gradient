{ extend, Tween, type, Color } = $

_prop = 'backgroundImage'
_unit = 'px'

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

_init = ( tween ) ->
  { elem, end } = tween

  extend tween,
   start: _parse $( elem ).css _prop
   end: _parse end
   set: yes
   unit: if end.indexOf '%' > -1
             '%'
         else
             'px'

_parse = ( val ) ->
  for image in _top_level_args val
      do ->
       _match =
        ///
         linear-gradient\(
         \s *
         (
          - ?
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
        ///.exec image

       return image unless _match

       [ all, angle, _stops ] = _match

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
       angle:
        _int angle
       stops:
        stops

_prop_val = ( tween ) ->
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
         "linear-gradient( #{ _scaled ( val ) -> val.angle }deg, #{ ( "#{ stop.color } #{ stop.pos }#{ unit }" for stop in _stops ).join ', ' } )" )
   .join ', '

extend Tween.propHooks,
 linearGradient:
  get: ( tween ) ->
    _parse $( tween.elem ).css _prop
  set: ( tween ) ->
    _init tween unless tween.set

    $( tween.elem )
     .css _prop,
          _prop_val tween
