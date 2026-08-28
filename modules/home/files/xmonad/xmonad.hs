import XMonad hiding (resizeWindow)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Actions.Minimize
import XMonad.Actions.Submap (submap)
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.LayoutCombinators (JumpToLayout(..))
import XMonad.Layout.Accordion (Accordion(..))
import XMonad.Layout.Minimize (minimize)
import XMonad.Layout.Renamed (renamed, Rename(..))
import XMonad.Layout.Spacing (spacingRaw, Border(..))
import XMonad.Layout.Tabbed (tabbed, shrinkText, Theme(..))
import XMonad.Layout.ToggleLayouts (toggleLayouts, ToggleLayout(..))
import XMonad.Layout.ResizableTile (MirrorResize(..))
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Types (Direction2D(..))

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import System.Exit (exitSuccess)
import System.IO

main :: IO ()
main = do
  xmproc <- spawnPipe "bash -lc 'pkill -x xmobar >/dev/null 2>&1 || true; exec xmobar /home/yoptabyte/.config/xmobar/xmobarrc'"
  xmonad $ docks $ ewmh $ def
    { modMask            = mod4Mask
    , terminal           = "st"
    , borderWidth        = 2
    , normalBorderColor  = "#c9cbd1"
    , focusedBorderColor = "#cc6d00"
    , workspaces         = map show [1..10]
    , layoutHook         = myLayout
    , manageHook         = myManageHook
    , logHook            = dynamicLogWithPP xmobarPP
                            { ppOutput = hPutStrLn xmproc
                            , ppTitle  = const ""
                            , ppCurrent = xmobarColor "#cc6d00" "" . wrap "[" "]"
                            , ppVisible = xmobarColor "#716e61" ""
                            , ppHidden  = xmobarColor "#716e61" ""
                            , ppHiddenNoWindows = xmobarColor "#8a8980" ""
                            , ppUrgent  = xmobarColor "#c84053" "" . wrap "!" "!"
                            , ppLayout  = xmobarColor "#597b75" "" . layoutName
                            , ppSep     = "<fc=#8a8980> | </fc>"
                            , ppOrder   = \(ws:l:t:ex) -> [ws, l]
                            }
    , startupHook        = myStartupHook
    } `additionalKeysP` myKeys

myTabTheme :: Theme
myTabTheme = def
  { activeColor      = "#cc6d00"
  , inactiveColor    = "#c9cbd1"
  , activeBorderColor  = "#cc6d00"
  , inactiveBorderColor = "#c9cbd1"
  , activeTextColor  = "#f2ecbc"
  , inactiveTextColor = "#716e61"
  }

layoutName :: String -> String
layoutName s = case words s of
  [] -> ""
  xs -> last xs

myLayout = minimize
         $ smartBorders
         $ avoidStruts layouts
         `toggleLayouts` Full
  where
    spaced = spacingRaw True (Border 6 6 6 6) True (Border 3 3 3 3) True
    layouts =
      renamed [Replace "Tall"] (spaced (Tall 1 (3/100) (1/2)))
      ||| renamed [Replace "Mirror"] (spaced (Mirror (Tall 1 (3/100) (1/2))))
      ||| renamed [Replace "Stack"] (spaced Accordion)
      ||| renamed [Replace "Tabbed"] (spaced (tabbed shrinkText myTabTheme))

toggleFloating :: Window -> X ()
toggleFloating w = do
  ws <- gets windowset
  if M.member w (W.floating ws)
    then do
      windows $ W.sink w
      refresh
    else do
      windows $ W.float w (W.RationalRect 0.1 0.1 0.8 0.8)
      windows $ W.focusWindow w

resizeWindow :: Direction2D -> X ()
resizeWindow dir =
  let resizeTiled L = sendMessage Shrink
      resizeTiled R = sendMessage Expand
      resizeTiled U = sendMessage MirrorShrink
      resizeTiled D = sendMessage MirrorExpand
      step = 0.05
      adjustRect L (W.RationalRect x y ww hh) = W.RationalRect (x + step) y (ww - step) hh
      adjustRect R (W.RationalRect x y ww hh) = W.RationalRect x y (ww + step) hh
      adjustRect U (W.RationalRect x y ww hh) = W.RationalRect x (y + step) ww (hh - step)
      adjustRect D (W.RationalRect x y ww hh) = W.RationalRect x y ww (hh + step)
  in withFocused $ \w -> do
    ws <- gets windowset
    case M.lookup w (W.floating ws) of
      Just r -> windows $ W.float w (adjustRect dir r)
      Nothing -> resizeTiled dir

myManageHook = composeOne
  [ className =? "Gimp" -?> doFloat
  , className =? "Vlc"  -?> doFloat
  ]

myStartupHook = do
  spawn "systemctl --user unset-environment WAYLAND_DISPLAY && systemctl --user import-environment DISPLAY && systemctl --user start emacs-x11.service"
  spawn "xrdb -merge ~/.Xresources"
  spawn "pkill -x trayer >/dev/null 2>&1 || true"
  spawn "pkill -x snixembed >/dev/null 2>&1 || true"
  spawn "trayer --edge bottom --align right --widthtype request --width 1 --height 22 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x282828 --expand false --padding 2 --iconspacing 2 --monitor primary"
  spawn "snixembed"

myKeys =
  [ ("M-Return",        spawn "st")
  , ("M-d",             spawn "vicinae open")
  , ("M-p",             spawn "/home/yoptabyte/.local/bin/dmenu_run")
  , ("M-S-d",           spawn "/home/yoptabyte/.local/bin/dmenu_run")
  , ("M-q",             kill)
  , ("M-S-c",           spawn "xmonad --recompile && xmonad --restart")
  , ("M-S-e",           io exitSuccess)
  , ("M-j",             windows W.focusDown)
  , ("M-k",             windows W.focusUp)
  , ("M-h",             windows W.focusDown)
  , ("M-l",             windows W.focusUp)
  , ("M-<Left>",        windows W.focusDown)
  , ("M-<Down>",        windows W.focusDown)
  , ("M-<Up>",          windows W.focusUp)
  , ("M-<Right>",       windows W.focusUp)
  , ("M-S-j",           windows W.swapDown)
  , ("M-S-k",           windows W.swapUp)
  , ("M-S-h",           windows W.swapDown)
  , ("M-S-l",           windows W.swapUp)
  , ("M-S-<Left>",      windows W.swapDown)
  , ("M-S-<Down>",      windows W.swapDown)
  , ("M-S-<Up>",        windows W.swapUp)
  , ("M-S-<Right>",     windows W.swapUp)
  , ("M-1",             windows $ W.greedyView "1")
  , ("M-2",             windows $ W.greedyView "2")
  , ("M-3",             windows $ W.greedyView "3")
  , ("M-4",             windows $ W.greedyView "4")
  , ("M-5",             windows $ W.greedyView "5")
  , ("M-6",             windows $ W.greedyView "6")
  , ("M-7",             windows $ W.greedyView "7")
  , ("M-8",             windows $ W.greedyView "8")
  , ("M-9",             windows $ W.greedyView "9")
  , ("M-0",             windows $ W.greedyView "10")
  , ("M-S-1",           windows $ W.shift "1")
  , ("M-S-2",           windows $ W.shift "2")
  , ("M-S-3",           windows $ W.shift "3")
  , ("M-S-4",           windows $ W.shift "4")
  , ("M-S-5",           windows $ W.shift "5")
  , ("M-S-6",           windows $ W.shift "6")
  , ("M-S-7",           windows $ W.shift "7")
  , ("M-S-8",           windows $ W.shift "8")
  , ("M-S-9",           windows $ W.shift "9")
  , ("M-S-0",           windows $ W.shift "10")
  , ("M-b",             sendMessage $ JumpToLayout "Tall")
  , ("M-v",             sendMessage $ JumpToLayout "Mirror")
  , ("M-s",             sendMessage $ JumpToLayout "Stack")
  , ("M-w",             sendMessage $ JumpToLayout "Tabbed")
  , ("M-e",             sendMessage NextLayout)
  , ("M-f",             sendMessage ToggleLayout)
  , ("M-t",             withFocused toggleFloating)
  , ("M-S-space",       withFocused toggleFloating)
  , ("M-S-minus",       withFocused minimizeWindow)
  , ("M-minus",         withLastMinimized maximizeWindowAndFocus)
  , ("M-Tab",           windows W.focusDown)
  , ("M-S-Tab",         windows W.focusUp)
  , ("M-C-h",           resizeWindow L)
  , ("M-C-j",           resizeWindow D)
  , ("M-C-k",           resizeWindow U)
  , ("M-C-l",           resizeWindow R)
  , ("M-C-<Left>",      resizeWindow L)
  , ("M-C-<Down>",      resizeWindow D)
  , ("M-C-<Up>",        resizeWindow U)
  , ("M-C-<Right>",     resizeWindow R)
  , ("M-r",             submap $ M.fromList
                          [ ((0, xK_h), resizeWindow L)
                          , ((0, xK_j), resizeWindow D)
                          , ((0, xK_k), resizeWindow U)
                          , ((0, xK_l), resizeWindow R)
                          , ((0, xK_Left), resizeWindow L)
                          , ((0, xK_Down), resizeWindow D)
                          , ((0, xK_Up), resizeWindow U)
                          , ((0, xK_Right), resizeWindow R)
                          , ((0, xK_Return), pure ())
                          , ((0, xK_Escape), pure ())
                          ])
  , ("<Print>",         spawn "scrot -s -e 'xclip -selection clipboard -t image/png $f && rm $f'")
  , ("M-<Print>",       spawn "scrot -s ~/Pictures/screenshot-%Y-%m-%d-%H%M%S.png")
  , ("<XF86AudioRaiseVolume>",  spawn "pulsemixer --change-volume +5")
  , ("<XF86AudioLowerVolume>",  spawn "pulsemixer --change-volume -5")
  , ("<XF86AudioMute>",         spawn "pulsemixer --toggle-mute")
  , ("<XF86AudioMicMute>",      spawn "pulsemixer --list-sources 2>/dev/null | head -1 | xargs -r pulsemixer --toggle-mute --id")
  , ("<XF86MonBrightnessUp>",   spawn "brightnessctl set +5%")
  , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 5%-")
  , ("M-S-x",           spawn "xsecurelock")
  ]
