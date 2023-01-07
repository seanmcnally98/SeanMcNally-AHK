; BEFORE RUNNING:
; Create a multicam sequence from your cameras (by Timecode, Ignore hours), put it on V2
;
; Select all your clips on V1, and use the Info window to see how many clips you have
;
; Go to Edit>Keyboard Shortcuts and add these three keyboard shortcuts: 
; F2 for Rename Clip, Ctrl+Shift+1 for Toggle Target Video 1, Ctrl+Shift+2 for Toggle Target Video 2.
;
; MAKE SURE you deselect each track, make sure none of them (V1, V2, A2, etc.) have a blue square.
; THIS IS CRITICAL, if any are active when you run the script it simply won't work!
;
; Extra Tip: Change the numbers of cameras per page to your preference before cutting, since you can't mass edit that setting afterwards.
; You can do this by Activating V2, selecting your clip, clicking the wrench, and choosing "Edit Cameras".  Make sure to deactivate V2 again before running.

SplashTextOff
panic = false

;Panic button is Shift + Escape, just in case something goes wrong.
+Esc::
panic = true
SplashTextOff
reload
return

; Make sure Premiere is the active window before executing
#IfWinActive ahk_class Premiere Pro

; This is the key that executes the commmand.  I chose backtick/tilde since nobody ever uses that key.

`::

; Creates an input box to allow you to specify your number of clips
InputBox, NumClips, Number of Clips, Please enter the number of clips on V1, Width, Height, X, Y, Locale, Timeout, Default

;The clips take half a second each, from that we can determine a rough time estimate.
TimeEst := NumClips*0.75
TimeEst := TimeEst/60
TimeEst := Ceil(TimeEst)

; Bring up a dialog box so that the user doesn't touch anything and mess up the whole thing.
SplashTextOn ,500 ,200 , Splash, Hold on, turning %NumClips% single-cam clips into muti-camera edits. `n`nDon't touch your keyboard or mouse for roughly %TimeEst% minute(s), or until this message disappears.`n`nIf you need to cancel, press Shift+Escape

; Give the computer a second, then make sure Premiere is activated.
sleep 100
WinActivate ahk_class Premiere Pro

; Set up our panic button, just in case.
panic = false

; Activate V1 before the first loop. 
Send ^+1
Loop %NumClips%                           	;The number is the amount of times this code is looped, based on what the user entered.
{
	if panic = true				; If we pressed the stop button, stop.
		break
	Send d					; Select clip at playhead
	Send {F2}				; Open the rename dialog box
	sleep 125				; Let Premiere catch up
	Send ^c					; Copy the clip name to the clipboard
	Send {Esc}				; Close the rename dialog box.
	StringRight, Trimmed1, clipboard, 5	; Trim the clipboard so we're just looking at the last 5 characters.  
						; Since it'll be "[Project Name] Cam X.mp4", this function will
						; trim it down to "X.mp4"
	StringLeft, CamChoice, Trimmed1, 1	; This just looks at the very first character in "X.mp4", so we get the proper camera angle.
	sleep 75				; Let Premiere catch up
	Send ^+1				; Deactivate V1
	sleep 75				; Let Premiere catch up
	Send ^+2				; Activate V2
	sleep 75				; Let Premiere catch up
	Send d					; Select clip at playhead
	Send ^k					; Add edit to selected clip
	Send ^{Down}				; Select our newly edited clip
	sleep 100				; Let Premiere catch up
	Send %CamChoice%			; Change the camera angle on our new clip
	sleep 75				; Let Premiere catch up
	Send ^+2				; Deactivate V2
	sleep 75				; Let Premiere catch up
	Send ^+1				; Activate V1
	Send {Down}				; Move to the next clip on V1, then start over
}
SplashTextOff
ExitApp
return	; Notes that we're done specifying what to do when you press the hotkey tilde.

