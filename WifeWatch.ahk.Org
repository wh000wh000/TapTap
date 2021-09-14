Class WifeWatch {
	static thisObject := ""
	static WatchTitle := "WifeWatch"
	static activeWindow := ""

	__New() {
		thisObject := this
		this.SaveActiveWindow()

		Gui, WifeWatch:New, +AlwaysOnTop -SysMenu -Caption +ToolWindow, % WifeWatch.WatchTitle
		Gui, WifeWatch:Color, Yellow
		Gui, WifeWatch:Margin, 4, 0
		Gui, WifeWatch:Font, S38 Bold W1000 Q4, 나눔 고딕

		FormatTime, timeString, , hh:mm
		Gui, WifeWatch:Add, Text, v__WatchDisplay Center cBlack, %timeString%
		; Known limitation: SetTimer requires a plain variable reference.
		this.timer := ObjBindMethod(this, "RedrawWatchTime")
		timer := this.timer
		SetTimer, % timer, -250

		watchDragger := ObjBindMethod(this, "DragWatch")
		GuiControl +g, __WatchDisplay, % watchDragger
		Gui, WifeWatch:Show, X2160 Y0

		this.RestoreActiveWindow()
	}

	RestoreActiveWindow() {
		SetTitleMatchMode, 2
		WinActivate, % WifeWatch.activeWindow
	}

	SaveActiveWindow() {
		title = WinExist("A")
		if (!title) {
			MouseGetPos, , , title
		}
		WifeWatch.activeWindow := title
	}

	RedrawWatchTime() {
		global __WatchDisplay
		; FormatTime, timeString, , MM/dd ddd hh:mm:ss 월/일 요일 시:분:초
		FormatTime, timeString, , hh:mm
		GuiControl, WifeWatch:Text, __WatchDisplay, %timeString%

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
