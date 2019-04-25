breed [horses horse]
breed [stats stat]
stats-own [name places shows thirds]
horses-own [name avg_speed std_speed horse_wps_ratio jockey_wps_ratio gate_position curspeed curaccel distancetravelled laps_completed prevX prevY place] ;; has default parameters xcor, ycor, and heading
globals [params
  count_finished
  total_runs
  timestep
  laps_needed
  finish_x
  finish_y_high_or_low?
  ]
;; tmp

to setup-horses
  set-default-shape horses "horse" ;; set the shape of the agents
  if (NUMBER_OF_HORSES > 12) ;; the track is only made to fit 12 horses
  [
    error "MAXIMUM HORSES: 12"
  ]
  set timestep 0.03 ;; set the timestep
  set params (list)
  let horseIndex 0
  foreach ["NAME:" "SPEED AVG:" "SPEED STD:" "WPS RATIO HORSE:" "WPS RATIO JOCKEY:" "GATE POSITION:"]
  [
    x -> parse x horseIndex
    set horseIndex horseIndex + 1
  ]
  ;;output-print params
  let horse_idx 0
  while [horse_idx < NUMBER_OF_HORSES]
  [
    let m_name (item (5 * NUMBER_OF_HORSES + horse_idx) params)
    let m_speed_avg (item (4 * NUMBER_OF_HORSES + horse_idx) params)
    let m_speed_std (item (3 * NUMBER_OF_HORSES + horse_idx) params)
    let m_wps_horse (item (2 * NUMBER_OF_HORSES + horse_idx) params)
    let m_wps_jockey (item (1 * NUMBER_OF_HORSES + horse_idx) params)
    let m_gate_position (item (0 * NUMBER_OF_HORSES + horse_idx) params)
    create-horses 1 [
     set name m_name
     set avg_speed read-from-string m_speed_avg
     set std_speed read-from-string m_speed_std
     set horse_wps_ratio read-from-string m_wps_horse
     set jockey_wps_ratio read-from-string m_wps_jockey
     set gate_position read-from-string m_gate_position
     set heading 90
     set size 3
     ;; parse length
     let start 0
     ifelse (LENGTH_RACE = 5.5)[
        set start 20
        set laps_needed 1
        set finish_x 23.232852774
        set finish_y_high_or_low? "high"
      ]
     [
      ifelse (LENGTH_RACE = 8)[
          set start 40
          set laps_needed 1
          set finish_x 39.6116208
          set finish_y_high_or_low? "low"
        ]
      [
       ifelse (LENGTH_RACE = 6)[
          set start 40
          set laps_needed 1
          set finish_x 54.15465269
          set finish_y_high_or_low? "high"
          ]
       [
         error "Shouldn't see message"
       ]
      ]
     ]
     set laps_completed 0
     setxy start (-19 + (gate_position * 0.3309255871)) ; there are 0.1985553523for 10 feet (width)
     ;; set curspeed based on a boost
     if (bernoulli horse_wps_ratio)[
       set curspeed BOOST
      ]
     set curaccel 20000 ;; miles/hour^2
    ]

    ;; set up stats but only on first trial
    if (total_runs = 1)
    [
      create-stats 1 [
        set name m_name
        set places 0
        set shows 0
        set thirds 0
      ]
    ]

    set horse_idx horse_idx + 1
  ]
end

to parse [x index]
  let start position x AGENT_PARAMETERS
  let input substring AGENT_PARAMETERS start length(AGENT_PARAMETERS)
  set start length(x)
  let endOfLine position "\n" input
  let parsedParams 0 ;; used for error checking
  if (member? x input)[
     let endOfParam position "," input
     while [not is-boolean? endOfParam and endOfLine > endOfParam][
       let param substring input start endOfParam
       set param remove " " param
       set params fput param params
       set input substring input (endOfParam + 1) length(input)
       set start 0
       set endOfParam position "," input
       set endOfLine position "\n" input
       set parsedParams parsedParams + 1
    ]
  ]
  if (parsedParams != NUMBER_OF_HORSES)
  [
    error insert-item 14 "INVALID INPUT Too few/many parameters: " x
  ]
end


to setup-patches
  let track_straight_length 40
  ask patches [
   set pcolor green
  ]
  let idx 0
  while [idx < track_straight_length]
  [
   let xcor_out 20 + idx
   ask patch xcor_out -4 [ set pcolor brown]
   ask patch xcor_out -19 [ set pcolor brown]
   ask patch xcor_out -34 [ set pcolor brown]
   ask patch xcor_out -49 [ set pcolor brown]
   set idx idx + 1
  ]
  ;; extend 7 on both sides of outside
  let i 1
  while [ i <= 7 ]
  [
   ask patch (20 - i) -4 [ set pcolor brown]
   ask patch (59 + i) -4 [ set pcolor brown]
   ask patch (20 - i) -49 [ set pcolor brown]
   ask patch (59 + i) -49 [ set pcolor brown]
   set i i + 1
  ]
  ;; draw inner-circle
  ;; draw line from (63,-22) -> (63,-31)
  ;; draw line from (17,-22) -> (17,-31)
  set i -22
  while [i > -32]
  [
    ask patch 63 i [set pcolor brown]
    ask patch 17 i [set pcolor brown]
    set i i - 1
  ]
  ;; draw lines for inner-track
  set i 0
  let j1 60
  let j2 17
  while [ j1 < 63]
  [
    ask patch j1 (-19 - i) [set pcolor brown]
    ask patch j1 (-34 + i) [set pcolor brown]
    ask patch j2 (-22 + i) [set pcolor brown]
    ask patch j2 (-31 - i) [set pcolor brown]
    set j1 j1 + 1
    set j2 j2 + 1
    set i i + 1
  ]
  ;; draw outer-circle
  ;; draw line from (78,-15)->(78,-38)
  ;; draw line from (2,-15)->(2,-38)
  set i -15
  while [i >= -38]
  [
    ask patch 78 i [set pcolor brown]
    ask patch 2 i [set pcolor brown]
    set i i - 1
  ]
  set i 0
  set j1 78
  set j2 2
  while [ j1 >= 67]
  [
    ask patch j1 (-15 + i) [set pcolor brown]
    ask patch j1 (-38 - i) [set pcolor brown]
    ask patch j2 (-15 + i) [set pcolor brown]
    ask patch j2 (-38 - i) [set pcolor brown]
    set j1 j1 - 1
    set j2 j2 + 1
    set i i + 1
  ]
  ;; draw finish line
  ifelse (finish_y_high_or_low? = "high")
  [
    let y -18
    while[y < -4][
      ask patch finish_x y [set pcolor white]
      set y y + 1
    ]
  ]
  [
   let y -48
   while[y < -34][
     ask patch finish_x y [set pcolor white]
     set y y + 1
   ]
  ]

end


to setup
  clear-all
  set total_runs 1
  set count_finished 1
  setup-horses
  setup-patches
  reset-ticks
  reset-timer
end

to rerun
  set total_runs (total_runs + 1)
  set count_finished 1
  setup-horses
  reset-ticks
  reset-timer
end

to update-heading
  ;; get general sense of direction
  ;output-print ycor
  ifelse (xcor >= 20 and xcor <= 60)
  [
    ifelse (ycor <= -22) [ set heading towardsxy 20 -34 ];; # bottom straight
      [ set heading towardsxy 60 -19  ];; # upper straight
  ]
  [
    ifelse (xcor < 20)
    [
     if(ycor >= -49 and ycor < -31) [ set heading towardsxy 17 -31 ] ;; bottom left
     if(ycor >= -31 and ycor < -22) [ set heading towardsxy 17 -22] ;; left
     if(ycor >= -22 and ycor < -4 ) [ set heading towardsxy 20 -19 ]  ;; upper left
    ]
    [
     if(ycor >= -49 and ycor < -31) [ set heading towardsxy 60 -34 ] ;; bottom right
     if(ycor >= -31 and ycor < -22) [ set heading towardsxy 63 -31 ] ;; right
     if(ycor >= -22 and ycor < -4 ) [ set heading towardsxy 63 -22  ] ;; upper right
    ]
  ]
  ;; looks at the 8 patches around the turtle
  ask neighbors [
     if (pcolor = brown)[
      ;; probably something to do with myself
     ]
     ask turtles-here [
      ;;show name
       ;;output-print distance myself ;; outputs distance to turtles on this specific patch
    ]
  ]
end

; horse procedure; accelerate
to move-forward
   set prevX xcor
   set prevY ycor
   update-heading
   let prevspeed curspeed
   ifelse (abs (curspeed - avg_speed) < std_speed * 2 or (curspeed - avg_speed) > 3 * std_speed) ;; if we are within 2 standard deviations of the speed, randomly decide speed
    [
      set curspeed random-normal avg_speed std_speed
    ]
    [
      set curspeed (curspeed + curaccel * (timestep / 3600 ))
    ]
  ;; boost the horse if they win the bernoulli trial
  if (bernoulli horse_wps_ratio)[
    set curspeed curspeed + random-normal 0 .5
  ]
  set distancetravelled distancetravelled + (prevspeed * (timestep / 3600) ) + (0.5 * curaccel * ( (timestep / 3600) ^ 2 ))
  fd ((prevspeed * (timestep / 3600) ) + (0.5 * curaccel * ( (timestep / 3600) ^ 2 ))) * 174.72871
end

; see if a horse is finished
to finished?
  ifelse (finish_y_high_or_low? = "high")
  [
    if (ycor > -24 and prevX <= finish_x and xcor >= finish_x)[set laps_completed laps_completed + 1]
  ]
  [
    if (ycor < -24 and prevX >= finish_x and xcor <= finish_x)[set laps_completed laps_completed + 1]
  ]
  if (laps_completed > laps_needed) [

    if (count_finished = 1)
    [
      ask stats with [name = ([name] of myself)][set places (places + 1)]
    ]
    if (count_finished = 2)
    [
      ask stats with [name = ([name] of myself)][set shows (shows + 1)]
    ]
    if (count_finished = 3)
    [
      ask stats with [name = ([name] of myself)][set thirds (thirds + 1)]
    ]

    set count_finished (count_finished + 1)
    die
  ]
end

to-report bernoulli [p]
  report ((random-float 1) < p )
end

to resolve-conflicts
  ask horses in-radius 0.1985553523 ;; ask horses that are within 6 ft of this horse
  [
    if(xcor != [xcor] of myself and ycor != [ycor] of myself)[
      ifelse (prevX >= 20 and prevX <= 60)
      [
        ifelse (prevY <= -22) [ set heading 270 ];; #1
        [ set heading 90  ];; #2
      ]
      [
        ifelse (prevX < 20)
        [
          if(prevY >= -49 and prevY < -33) [ set heading 315 ]
          if(prevY >= -33 and prevY < -22) [ set heading 0 ]
          if(prevY >= -22 and prevY < -4 ) [ set heading 45 ]
        ]
        [
          if(prevY >= -49 and prevY < -34) [ set heading 225 ]
          if(prevY >= -34 and prevY < -22) [ set heading 180 ]
          if(prevY >= -22 and prevY < -4 ) [ set heading 135  ]
        ]
      ]
    ]
  ]
end

to print_avg_place
  output-show name ( places / total_runs )
end

to go
  ;;output-print ticks
  ask horses with [laps_completed <= laps_needed][move-forward]
  ask horses with [laps_completed <= laps_needed][finished?]
  tick-advance timestep
  if (all? horses [laps_completed > laps_needed])
  [
    rerun
    ask horses [print_avg_place]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
200
10
1261
734
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
80
-54
0
0
0
1
ticks
30.0

TEXTBOX
1299
57
1854
289
SETUP AGENTS\n1. Enter horse's name if selected\n2. Enter average/standard deviation of horse speed (mph)\n3. Enter win-place-show ratio of horse\n->(wins+places+shows)/total races\n4. Enter win-place-show ratio of jockey\n5. Enter gate position of horse\nEX.\nNAME: horse1_name, horse2_name,...\nSPEED AVG: horse1_speed, horse2_speed,...\nNote: Must be iterable (, at end) and each line separated by newline (\\n) including last line.
12
0.0
1

TEXTBOX
25
19
175
151
ENVIRONMENT SETUP\n1. Enter length of race\n2. Enter number of horses
15
0.0
1

BUTTON
56
366
136
438
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1294
264
1904
557
AGENT_PARAMETERS
NAME: horse1_name,horse2_name,horse3_name,horse4_name,horse5,\nSPEED AVG: 35.321,34.3214,35.3424,34.323,33,\nSPEED STD: 1.232,1.231,0.4321,3.2314,1.2,\nWPS RATIO HORSE: 0.342,0.343,0.231,0.14321,0.432,\nWPS RATIO JOCKEY: 0.3242,0.432,0.4321,0.1342,0.4320,\nGATE POSITION: 3,4,1,2,5,\n
1
1
String

INPUTBOX
14
232
188
307
NUMBER_OF_HORSES
5.0
1
0
Number

BUTTON
58
456
137
521
go
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

CHOOSER
30
174
168
219
LENGTH_RACE
LENGTH_RACE
5.5 8 6
0

SLIDER
14
316
186
349
BOOST
BOOST
0
5
5.0
1
1
mph
HORIZONTAL

OUTPUT
1320
579
1866
701
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

horse
true
8
Rectangle -6459832 true false 120 45 180 255
Circle -1 true false 105 15 90
Polygon -11221820 true true 120 150 180 150 165 195 150 150 135 195 120 150
Polygon -11221820 true true 120 210 180 210 180 225 120 225 120 210 135 195 150 210 165 195 180 210
Polygon -11221820 true true 120 150 135 120 150 150 165 120 180 150 120 135 180 120 120 120 180 135 120 150
Polygon -11221820 true true 120 165 180 180 120 195 180 195 120 180 180 165
Rectangle -6459832 true false 105 210 120 225
Rectangle -6459832 true false 105 135 120 150
Rectangle -6459832 true false 180 135 195 150
Rectangle -6459832 true false 180 210 195 225
Rectangle -6459832 true false 135 255 150 255
Rectangle -6459832 true false 135 270 165 270
Rectangle -6459832 true false 135 255 165 270

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
