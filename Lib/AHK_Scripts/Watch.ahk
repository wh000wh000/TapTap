Class Watch {
	static thisObject := ""
	static WatchTitle := "TapTap_Watch"
	static __WatchDisplay := ""
	__New() {
		WinGetActiveTitle, activeWindowTitleBeforeWatchOn

		Gui, Watch:New, +AlwaysOnTop -SysMenu -Caption +ToolWindow, % Watch.WatchTitle
		Gui, Watch:Color, Yellow
		Gui, Watch:Margin, 4, 0
		Gui, Watch:Font, S38 Bold W1000 Q4, 나눔 고딕

		FormatTime, timeString, , hh:mm
		Gui, Watch:Add, Text, v__WatchDisplay Center cBlack, %timeString%
		; Known limitation: SetTimer requires a plain variable reference.
		this.timer := ObjBindMethod(this, "RedrawWatchTime")
		timer := this.timer
		SetTimer, % timer, -250

		global __WatchDisplay
		watchDragger := ObjBindMethod(this, "DragWatch")
		GuiControl +g, __WatchDisplay, % watchDragger
		Gui, Watch:Show, X2160 Y0

		WinActivate , %activeWindowTitleBeforeWatchOn%
		thisObject := this
	}

	RedrawWatchTime() {
		global __WatchDisplay
		; FormatTime, timeString, , MM/dd ddd hh:mm:ss 월/일 요일 시:분:초
		FormatTime, timeString, , hh:mm
		GuiControl, Watch:Text, __WatchDisplay, %timeString%

		; 다음 시간 정밀 조정
		FormatTime, timeString, , ss
		nextMin := -((60 - timeString) * 1000)
		timer := this.timer
		SetTimer, % timer, % nextMin
	}

	DragWatch() {
		PostMessage, 0xA1, 2, , , A
		return
	}
}
