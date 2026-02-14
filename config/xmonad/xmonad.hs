{-# LANGUAGE DeriveDataTypeable, TypeApplications, LambdaCase #-}

import XMonad
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.SpawnOnce
import qualified XMonad.Util.ExtensibleState as XS
import qualified XMonad.Util.Paste as XP
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)
import System.IO
import XMonad.Actions.SpawnOn
-- import XMonad.Actions.PerWindowKeys
import XMonad.Actions.PerWorkspaceKeys
-- Brightness / Volume control
import Graphics.X11.ExtraTypes.XF86

-- General
myTerminal      = "alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth   = 1
myNormalBorderColor  = "#333333"
myFocusedBorderColor = "#00ccff"

-- mod1Mask = left alt, mod4Mask = windows key
myModMask       = mod1Mask

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

activeColor = "#00ccff"
inactiveColor = "#ffffff"
separatorColor = "#ffffff"
urgentColor = "#ff0000"

------------------------------------------------------------------------
-- Define Workspaces
------------------------------------------------------------------------
myWorkspaces = ["木", "火", "土", "金", "水", "生", "克"] ++ map show [8..9]

workspaceModkeys =
  [ 
    (mod1Mask, ["木","火","土","金","水","克"] ++ map show [8..9])
    ,(mod4Mask, ["生"])
  ]

------------------------------------------------------------------------
-- Helper functions
------------------------------------------------------------------------
toggleFull :: X ()
toggleFull = withFocused (\windowId -> do
    { floats <- gets (W.floating . windowset);
        if windowId `M.member` floats
        then withFocused $ windows . W.sink
        else withFocused $ windows . (flip W.float $ W.RationalRect 0 0 1 1) })

onWorkspacesNot :: [String] -> X () -> X ()
onWorkspacesNot ws action = do
  current <- gets (W.currentTag . windowset)
  if current `notElem` ws then action else pure ()

wrapKey :: ((KeyMask, KeySym), X ()) -> ((KeyMask, KeySym), X ())
wrapKey ((mask, key), action) = ((mask, key), do
    ws <- gets windowset
    if W.currentTag ws == "生"
        then XP.sendKey mask key
        else action)

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------
fullKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
fullKeys conf@(XConfig { XMonad.modMask = modm }) =
  M.fromList $
    ( -- mod-[1..9]: switch/move to workspace N
      [ ((m .|. modm, k), onWorkspacesNot ["生"] $ windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      -- mod-{w,e,r}: switch/move to physical/Xinerama screens 1..3
      -- [ ((m .|. modm, key), onWorkspacesNot ["生"] $ screenWorkspace sc >>= flip whenJust (windows . f))
      --   | (key, sc) <- zip [xK_z, xK_x, xK_c] [0..]
      --   , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      -- ]
      -- ++
      -- Keymaps
      [ ((modm               , xK_Return)         , onWorkspacesNot ["生"] $ spawn $ XMonad.terminal conf)                                   -- launch a terminal
      , ((modm               , xK_space )         , onWorkspacesNot ["生"] $ spawn "dmenu_run -fn 'JetBrainsNerdMono:regular:pixelsize=18'") -- launch dmenu
      , ((modm               , xK_q     )         , onWorkspacesNot ["生"] $ kill)                                                           -- close focused window
      , ((modm               , xK_n     )         , onWorkspacesNot ["生"] $ refresh)                                                        -- resize viewed windows
      , ((modm               , xK_j     )         , onWorkspacesNot ["生"] $ windows W.focusDown)                                            -- focus next
      , ((modm               , xK_k     )         , onWorkspacesNot ["生"] $ windows W.focusUp)                                              -- focus previous
      , ((modm               , xK_m     )         , onWorkspacesNot ["生"] $ windows W.focusMaster)                                          -- focus master
      , ((modm .|. shiftMask , xK_Return)         , onWorkspacesNot ["生"] $ windows W.swapMaster)                                           -- swap with master
      , ((modm .|. shiftMask , xK_j     )         , onWorkspacesNot ["生"] $ windows W.swapDown)                                             -- swap down
      , ((modm .|. shiftMask , xK_k     )         , onWorkspacesNot ["生"] $ windows W.swapUp)                                               -- swap up
      , ((modm               , xK_h     )         , onWorkspacesNot ["生"] $ sendMessage Shrink)                                             -- shrink master
      , ((modm               , xK_l     )         , onWorkspacesNot ["生"] $ sendMessage Expand)                                             -- expand master
      , ((modm               , xK_comma )         , onWorkspacesNot ["生"] $ sendMessage (IncMasterN 1))                                     -- increment master
      , ((modm               , xK_period)         , onWorkspacesNot ["生"] $ sendMessage (IncMasterN (-1)))                                  -- decrement master
      , ((modm               , xK_v     )         , onWorkspacesNot ["生"] $ sendMessage ToggleStruts)                                       -- toggle struts
      , ((0                  , xF86XK_MonBrightnessUp)   , onWorkspacesNot ["生"] $ spawn "brightnessctl set +10% ")                         -- brightness up
      , ((0                  , xF86XK_MonBrightnessDown) , onWorkspacesNot ["生"] $ spawn "brightnessctl set 10%-")                          -- brightness down
      , ((modm .|. shiftMask , xK_q     )         , onWorkspacesNot ["生"] $ io (exitWith ExitSuccess))                                      -- quit xmonad
      , ((modm               , xK_t     )         , onWorkspacesNot ["生"] $ withFocused $ windows . W.sink)                                 -- push back into tiling
      , ((modm               , xK_r     )         , onWorkspacesNot ["生"] $ spawn "xmonad --recompile; xmonad --restart")                   -- restart xmonad
      , ((modm               , xK_Tab   )         , onWorkspacesNot ["生"] $ sendMessage NextLayout)                                         -- rotate layouts
      , ((modm .|. shiftMask , xK_Tab   )         , onWorkspacesNot ["生"] $ setLayout $ XMonad.layoutHook conf)                             -- reset layout
      , ((modm .|. shiftMask , xK_apostrophe)     , onWorkspacesNot ["生"] $ toggleFull)                                                     -- fullscreen toggle
      ]
    )

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf = M.union (M.fromList $ map wrapKey (M.toList (fullKeys conf))) freeKeys'
  where
    freeKeys' = M.fromList
      [ ((mod4Mask, xK_Return), onWorkspaces ["生"] $ spawn $ XMonad.terminal conf)
      , ((mod4Mask, xK_backslash), onWorkspaces ["生"] $ spawn "dmenu_run -fn 'JetBrainsNerdMono:regular:pixelsize=18'")
      , ((mod4Mask, xK_v), onWorkspaces ["生"] $ sendMessage ToggleStruts)
      , ((mod4Mask, xK_0), onWorkspaces ["生"] $ windows $ W.greedyView "木")
      , ((mod4Mask, xK_k), onWorkspaces ["生"] $ kill)
      ]

onWorkspaces :: [String] -> X () -> X ()
onWorkspaces ws action = do
  current <- gets (W.currentTag . windowset)
  if current `elem` ws then action else pure ()

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:
myLayout =  avoidStruts $ smartSpacing 3 $ smartBorders $ tiled ||| Mirror tiled ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--

myManageHook = composeAll . concat $
                [ [ manageDocks ]
                , [ className =? c --> doCenterFloat | c <- floats ]
                , [ className =? c --> doFullFloat | c <- fullFloats ]
                , [ resource =? r --> doIgnore | r <- ignore ]
                , [ resource =? "gecko" --> doF (W.shift "net") ]
                , [ isFullscreen --> doFullFloat ]
                , [ isDialog --> doCenterFloat ]
                ]
 where floats = ["nm-connection-editor", "Nm-connection-editor", "blueman-manager", "Blueman-manager", "vlc", "Vlc", "pavucontrol" ]
       fullFloats = ["Gimp"]
       ignore = ["stalonetray"]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--

------------------------------------------------------------------------
-- Startup hook
myStartupHook = do
    -- Setup desktop stuff like background, trayers, compositor etc.
    spawnOnce "~/dotfiles/config/xmonad/desktop-setup"
    spawn "~/dotfiles/config/xmonad/desktop-settings"
    spawn "~/dotfiles/config/xmonad/config-mouse"
    -- Start firefox and terminal on the respective workspace
    spawnOn "木" "alacritty"
    spawnOn "火" "librewolf"

myLogHook :: Handle -> X ()
myLogHook xmproc = dynamicLogWithPP $ xmobarPP
                { ppOutput = hPutStrLn xmproc,
                  ppCurrent = xmobarColor activeColor "" . wrap
                              "[ " " ]",
                  -- Visible but not current workspace
                  ppVisible = xmobarColor inactiveColor "",
                  -- Hidden workspace
                  ppHidden = xmobarColor inactiveColor "" . wrap
                              "[ " " ]",
                  -- Hidden workspaces (no windows)
                  -- ppHiddenNoWindows = xmobarColor inactiveColor "". wrap
                  --            "[ " " ]",
                  ppHiddenNoWindows = \str -> if str `elem` ["木","火","土","金","水"] 
                    then xmobarColor inactiveColor "" $ wrap "[ " " ]" str
                    else "",
                  ppTitle = (\str -> ""),
                  ppLayout = (\str -> ""),
                  -- Separator character
                  ppSep =  "<fc=" ++ separatorColor ++ "> <fn=1>|</fn> </fc>",
                  -- Urgent workspace
                  ppUrgent = xmobarColor urgentColor "" . wrap "!" "!",
                  -- Order of things in xmobar
                  ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                }

------------------------------------------------------------------------
main = do 
    xmproc <- spawnPipe "xmobar -x 0 ~/dotfiles/config/xmonad/xmobar.hs"
    xmonad $ docks $ ewmh def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = manageSpawn <+> myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook xmproc,
        startupHook        = myStartupHook
    }
