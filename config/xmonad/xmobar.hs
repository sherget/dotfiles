Config { font = "FiraCode-*-Fixed-Bold-R-Normal-*-9-*-*-*-*-*-*-*"
        , additionalFonts = ["xft:FontAwesome-9"]
        , borderColor = "black"
        , border = TopB
        , bgColor = "black"
        , fgColor = "grey"
        , position = TopH 20 TopW L 100
        , commands = [ Run Weather "EDDF" ["-t","<tempC>°C","-L","18","-H","25","--normal","#999999","--high","darkred","--low","lightblue"] 36000
                        , Run Network "wlp0s20f3" ["-L","0","-H","10000","--normal","green","--high","green"] 50
                        , Run Cpu ["-L","3","-H","50","--normal","green","--high","red"] 50
                        , Run Memory ["-t","Mem: <usedratio>%"] 50
                        , Run Date "%a %_d %b %Y %H:%M" "date" 600
                        , Run StdinReader
                        , Run Battery        [ "--template" , " 🔋 <acstatus>"
                             , "--Low"      , "10"        -- units: %
                             , "--High"     , "80"        -- units: %
                             , "--low"      , "darkred"
                             , "--normal"   , "#ffffff"
                             , "--high"     , "#00ccff"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% <fc=#00ccff>[</fc> <timeleft> <fc=#00ccff>]</fc>"
                                       -- AC "on" status
                                       , "-O"	, "<fc=#dAA520>Charging</fc>"
                                       -- charged status
                                       , "-i"	, "<fc=#006600>Charged</fc>"
                             ] 600
                     ]
        , sepChar = "%"
        , alignSep = "}{"
        , template = "%StdinReader%   %cpu% | %memory% | %wlp0s20f3% }<fc=#ffffff>%date%</fc> - %EDDF%{ | <fc=#ffffff>%battery%</fc> "
        }
