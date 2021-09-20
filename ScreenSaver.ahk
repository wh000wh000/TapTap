Class ScreenSaver {
	static thisObject := ""
	static isScreenSavering := false
	static right := ""
	static bottom := ""

	__New() {
		WinGetPos(, , &w, &h, "Program Manager")
		ScreenSaver.right := w - 1
		ScreenSaver.bottom := h - 1
		ScreenSaver.timer := ObjBindMethod(this, "RunScreenSaver")
		this.SetScreenSaverTime()
		thisObject := this
	}

	SetScreenSaverTime(interval := 300) {
		static baseInterval := 300
		if (baseInterval != interval) {
			baseInterval += 300
			if (baseInterval > interval) {
				baseInterval := interval
			}
		}
		timer := ScreenSaver.timer
		SetTimer(timer, baseInterval)
	}

	IsMouseOn() {
		if (SetUp.Get("NeedScreenSavering") = "false") {
			return false
		}
		onType := SetUp.Get("ScreenSaverOnMouse")
		CoordMode("Mouse", "Screen")
		MouseGetPos(&outX, &outY)
		switch (onType) {
			case "LeftTop":
				return outX = 0 and outY = 0
			case "RightTop":
				return outX = ScreenSaver.right and outY = 0
			case "LeftBottom":
				return outX = 0 and ScreenSaver.bottom = outY
			case "RightBottom":
				return outX = ScreenSaver.right and outY = ScreenSaver.bottom
			case "LeftWall":
				return outX = 0
			case "RightWall":
				return outX = ScreenSaver.right
			case "TopWall":
				return outY = 0
			case "BottomWall":
				return outY = ScreenSaver.bottom
			default:
				return false
		}
	}

	RunScreenSaver() {
		static screenSaverTime := 0
		if this.IsMouseOn() {
			If (ScreenSaver.isScreenSavering) {
				this.SetScreenSaverTime(3000)
				return
			}
			if (screenSaverTime = 0) {
				screenSaverTime := A_TickCount
			} else {
				elapsed := A_TickCount - screenSaverTime
				if (elapsed > 1000) {
					ScreenSaver.isScreenSavering := true
					; screenSaverTime := 0
					this.ActivateScreenSaver()
				}
			}
		} else {
			; find the screensaver (if any) and close it
			; for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process"){
			; 	if(InStr(process.Name, "scrnsave")){
			; 		Process, Close, % process.Name
			; 		Break
			; 	}
			; }
			ScreenSaver.isScreenSavering := false
			screenSaverTime := 0
			this.SetScreenSaverTime()
		}
	}

	ActivateScreenSaver() {
		; run, C:\Windows\System32\scrnsave.scr /s	; 가짜 화면 보호기

		;아래 화면 보호기는 윈도우에서 시간을 설정하고 사용해야 함
		HWND_BROADCAST := 0xffff
		WM_SYSCOMMAND  := 0x0112
		SC_SCREENSAVE  := 0xf140
		DllCall("PostMessage", "UPtr", HWND_BROADCAST, "UInt", WM_SYSCOMMAND, "UInt", SC_SCREENSAVE, "UInt", 0)
	}
}
