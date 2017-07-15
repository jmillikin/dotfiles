import           Control.Monad (when)
import           Control.Monad.Trans (liftIO)
import qualified Data.Map
import           Data.Monoid
import           Foreign.C.Types (CLong)

import           XMonad
import           XMonad.Config.Desktop
import           XMonad.Config.Gnome
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers (isFullscreen)
import           XMonad.Layout.Minimize
import           XMonad.Layout.MouseResizableTile
import           XMonad.Layout.NoBorders
import           XMonad.Util.Replace
import qualified XMonad.StackSet as W

main = do
	replace
	xmonad myConfig

myConfig = ewmh $ desktopConfig
	{ terminal = "gnome-terminal --disable-factory"
	, workspaces = map show [1..10]
	, keys = \c -> Data.Map.union (myKeys c) (workspaceKeys c)
	, modMask = mod4Mask
	, layoutHook = smartBorders $ minimize $ avoidStruts $ layouts
	, manageHook = manageHook desktopConfig <+> floatDialogs
	, handleEventHook = mconcat
		[ taskbarMinimizeEventHook
		, fullscreenEventHook
		, handleEventHook desktopConfig
		]
	, startupHook = startupHook gnomeConfig
	}

myKeys conf@(XConfig { modMask = modm }) = Data.Map.fromList $
	-- Launch a terminal
	[ ((modm .|. shiftMask, xK_Return), spawn $ terminal conf)
	
	-- Close focused window
	, ((modm .|. shiftMask, xK_c), kill)
	
	-- Rotate through the available layout algorithms
	, ((modm, xK_space), sendMessage NextLayout)
	
	-- Resize viewed windows to the correct size
	, ((modm, xK_n), refresh)
	
	-- Move focus to the next window
	, ((modm, xK_Tab), windows W.focusDown)
	
	-- Move focus to the next window
	, ((modm .|. shiftMask, xK_j), windows W.focusDown)
	
	-- Move focus to the previous window
	, ((modm .|. shiftMask, xK_k), windows W.focusUp)
	
	-- Move focus to the master window
	, ((modm, xK_m), windows W.focusMaster)
	
	-- Swap the focused window and the master window
	, ((modm, xK_Return), windows W.swapMaster)
	
	-- Swap the focused window with the next window
	, ((modm, xK_j), windows W.swapDown)
	
	-- Swap the focused window with the previous window
	, ((modm, xK_k), windows W.swapUp)
	
	-- Push window back into tiling
	, ((modm, xK_t), withFocused $ windows . W.sink)
	
	-- Increase the number of windows in the master area
	, ((modm, xK_comma), sendMessage (IncMasterN 1))
	
	-- Decrease the number of windows in the master area
	, ((modm, xK_period), sendMessage (IncMasterN (- 1)))
	
	-- Restart xmonad
	, ((modm, xK_q), spawn "xmonad --recompile; xmonad --restart")
	
	-- Launch GNOME "run" dialog
	, ((mod1Mask, xK_F2), gnomeRun)
	
	-- Lock screen
	, ((modm, xK_l), spawn "gnome-screensaver-command -l")
	
	-- Print screen
	, ((0, xK_Print), spawn "gnome-screenshot")
	
	]

workspaceKeys conf@(XConfig { modMask = modm }) = Data.Map.fromList $ do
	-- mod-[1..9], Switch to workspace N
	-- mod-shift-[1..9], Move client to workspace N
	--
	(workspaceName, key) <- zip (XMonad.workspaces conf) ([xK_1 .. xK_9] ++ [xK_0])
	[
		  ((modm, key), windows (W.greedyView workspaceName))
		, (((modm .|. shiftMask), key), windows (W.shift workspaceName))
		]

layouts = mouseResizableTile ||| mouseResizableTileMirrored ||| Full

isDialog :: Query Bool
isDialog = checkAtom "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_DIALOG"

role :: Query String
role = stringProperty "WM_WINDOW_ROLE"

floatDialogs = composeAll
	[ isDialog --> doFloat
	, role =? "gimp-dock" --> doFloat
	, role =? "gimp-toolbox" --> doFloat
	]

getProp :: Atom -> Window -> X (Maybe [CLong])
getProp a w = withDisplay $ \dpy -> io $ getWindowProperty32 dpy a w

checkAtom :: String -> String -> Query Bool
checkAtom name value = ask >>= \w -> liftX $ do
	a <- getAtom name
	val <- getAtom value
	mbr <- getProp a w
	case mbr of
		Just [r] -> return $ elem (fromIntegral r) [val]
		_ -> return False

taskbarMinimizeEventHook :: Event -> X All
taskbarMinimizeEventHook (ClientMessageEvent {ev_window = w, ev_message_type = mt}) = do
	a_aw <- getAtom "_NET_ACTIVE_WINDOW"
	a_cs <- getAtom "WM_CHANGE_STATE"
	a_st <- getAtom "WM_STATE"
	windowState <- getProp a_st w
	
	case windowState of
		Just (1:_) -> when (mt == a_cs) (minimizeWindow w)
		Just (3:_) -> when (mt == a_aw || mt == a_cs) (sendMessage (RestoreMinimizedWin w))
		_ -> return ()
	
	return (All True)
taskbarMinimizeEventHook _ = return (All True)
