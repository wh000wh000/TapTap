#Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
#SingleInstance Force
Persistent
FileEncoding("UTF-8")

TapTap()

; CapsLock 키 변경 to LControl by KeyTweak
; CapsLock Toggle 키 (CapsLock + 우측 Shift)
>+LControl::
{
	SetCapsLockState(!GetKeyState("CapsLock", "T"))
}

#Include "SetUp.ahk"
#Include "AliasList.ahk"

class TapTap {
	static arb := ""
	static arbEdit := ""
	static arbList := ""
	static arbEnter := ""
	static hotkey := ""
	static title := "ARB_TapTap"
	static activeWindowOnArb := ""
	static isArbShowing := false
	static isInputHighLighting := false

	__New() {
		;@Ahk2Exe-SetMainIcon TapTap.ico
		if (!A_IsCompiled)
			TraySetIcon("TapTap.ico")	; TapTap Icon

		this.InitTapTap()
		this.CreateARB()
	}


	; 프로그램 함수
	; Added bracket before function
	ShowAliasRunBox(_) {
		if (TapTap.isArbShowing)
			return
		If (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 350)
			this.ShowARB()
	}

	ARBGuiClose() {
		MsgBox("ARB Closed Check!")
	}

	HideARB() {
		timer := ObjBindMethod(this, "EscapeArbTimer")
		SetTimer(timer, 0)
		; ARB := Gui()
		TapTap.arb.Hide()
	}

	ARBGuiEscape(_) {
		this.HideARB()
		TapTap.isArbShowing := false

		SetTitleMatchMode(2)
		WinActivate(TapTap.activeWindowOnArb)
	}

	TabProcessTimer() {
		previousAlias := AliasList.previousAlias
		; GuiControl, , Edit1, % previousAlias	; 안 먹힘
		; ControlSend, Edit1, {Enter}, % TapTap.title
		ControlSend("{BackSpace}" . previousAlias . "{Enter}", "Edit1", TapTap.title)
	}

	TabDeleteTimer() {
		ControlSend("{Backspace}{Enter}", "Edit1", TapTap.title)
	}

	SpaceProcessTimer() {
		previousAlias := AliasList.previousAlias
		; GuiControl, , Edit1, % previousAlias	; 안 먹힘
		ControlSend("{End}{Space}", "Edit1", TapTap.title)
	}

	ARBGuiEditHandler(ab, _) {
		oSaved := TapTap.arb.Submit(false)
		arbEdit := TapTap.arbEdit.value

		; 입력란 하이라이트, Tab, Space 처리
		if (TapTap.isInputHighLighting) {
			TapTap.isInputHighLighting := false
			previousAlias := AliasList.previousAlias
			if InStr(arbEdit, A_Space) {
				TapTap.arbEdit.Value := previousAlias
				SetTimer(this.SpaceProcessTimer, -20)
				return
			}

			if InStr(arbEdit, A_Tab) {
				; GuiControl, , Edit1, % previousAlias
				SetTimer(this.TabProcessTimer, -20)
				return
			}
		} else if InStr(arbEdit, A_Tab) {
			SetTimer(this.TabDeleteTimer, -20)
			return
		}
		; 명령어 옵션을 입력하는 경우를 제외하고, 리스트 Update
		if (StrLen(arbEdit) = 1 or InStr(arbEdit, " ") = 0)
			this.UpdateListView(arbEdit)
	}

	ARBGuiEnterPressed(abc, i) {
		oSaved := TapTap.arb.Submit(false)
		arbEdit := TapTap.arbEdit.value
		this.HideARB()	; ARB 화면 죽인 후, 명령 실행
		res := AliasList.RunAlias(arbEdit)
		this.ARBGuiEscape("_")
		if InStr(res, "IniChanged") {
			this.SetHotkey()
		}
	}

	ImmediateRunTimer() {
		ControlSend("{Enter}", "Edit1", TapTap.title)
	}

	UpdateListView(alias_) {
		list := AliasList.ListAlias(alias_)
		length := list.Length
		if (length = 0) {
			TapTap.arbList.Opt("-Redraw")
			TapTap.arbList.Delete()
			TapTap.arbList.Opt("+Redraw")
			return
		}
		if (length = 1 and list[1] = "ImmediateRun") {
			timer := ObjBindMethod(this, "ImmediateRunTimer")
			SetTimer(timer, -20)
			return
		}
		TapTap.arbList.Opt("-Redraw")
		TapTap.arbList.Delete()
		For index, val in list
		{
			;LV_Insert(1, , val)
			TapTap.arbList.Add(, val)
		}
		TapTap.arbList.Modify(1, "Select")
		TapTap.arbList.Opt("+Redraw")
	}

	PreviousAliasSendTimer() {
		previousAlias := AliasList.previousAlias
		if (previousAlias = "") {
			ControlSend("^a{Space}{BackSpace}", "Edit1", TapTap.title)
		} else {
			ControlSend("^a" . previousAlias . "^a", "Edit1", TapTap.title)
			TapTap.isInputHighLighting := true
		}
	}

	ShowARB() {
		TapTap.isArbShowing := true

		this.SaveActiveWindow()

		CoordMode("Mouse", "Screen")
		MouseGetPos(&mouseX, &mouseY)
		posX := mouseX
		posY := mouseY
		if (A_ScreenWidth < mouseX + 410)
			posX := A_ScreenWidth - 410
		if (A_ScreenHeight < mouseY + 220)
			posY := A_ScreenHeight - 220
		TapTap.arb.Show("X" . posX . " Y" . posY)

		mouseX := posX + 100
		mouseY := posY + 15
		MouseMove(mouseX, mouseY)

		; SetTimer, PreviousAliasSendTimer, -10
		previousAlias := AliasList.previousAlias
		if (previousAlias = "") {
			ControlSend("^a{Space}{BackSpace}", "Edit1", TapTap.title)
		} else {
			ControlSend("^a" . previousAlias . "^a", "Edit1", TapTap.title)
			TapTap.isInputHighLighting := true
		}

		; SetTimer(EscapeArbTimer,1000)
	}

	SaveActiveWindow() {
		TapTap.activeWindowOnArb := WinExist("A")
		if (!TapTap.activeWindowOnArb) {
			MouseGetPos( , , &pos)
			TapTap.activeWindowOnArb := pos
		}
	}

	EscapeArbTimer() {
		if WinActive(TapTap.title) {
			return
		}

		this.SaveActiveWindow()

		ControlSend("{Escape}", "Edit1", TapTap.title)
	}

	CreateARB() {
		TapTap.arb := Gui(, TapTap.title)
		TapTap.arb.Opt("+AlwaysOnTop -Caption +ToolWindow")
		TapTap.arb.SetFont("S18 W1000", "나눔고딕")
		TapTap.arb.MarginX := "1", TapTap.arb.MarginY := "1"
		TapTap.arbEdit := TapTap.arb.Add("Edit", "w320 r1 WantTab vT_ArbEdit")
		editHandler := ObjBindMethod(this, "ARBGuiEditHandler")
		TapTap.arbEdit.OnEvent("Change", editHandler)

		TapTap.arb.SetFont("S12 W800", "나눔고딕")
		TapTap.arb.MarginX := "1", TapTap.arb.MarginY := "1"
		TapTap.arbList := TapTap.arb.Add("ListView", "R6 wp -Hdr ReadOnly vT_ArbList", ["1"])
		TapTap.arbEnter := TapTap.arb.Add("Button", "x-10 y-10 w1 h1 +default Hidden vT_ArbEnter")
		enterHandler := ObjBindMethod(this, "ARBGuiEnterPressed")
		TapTap.arbEnter.OnEvent("Click", enterHandler)	; Default Button Hidden
		escapeHandler := ObjBindMethod(this, "ARBGuiEscape")
		TapTap.arb.OnEvent("Escape", escapeHandler)
	}

	InitTapTap() {
		this.CreateFolder(A_WorkingDir . "\Lib")
		this.CreateFolder(A_WorkingDir . "\Lib\_SetUp")
		this.CreateFolder(A_WorkingDir . "\Lib\AHK")
		this.CreateFolder(A_WorkingDir . "\Lib\Python")
		; this.CreateFolder(A_WorkingDir . "\Src")

		this.CopyInitFiles()
		this.SetHotkey()
		AliasList.RunOnBoot()
	}

	SetHotkey() {
		try {
			hotkey_ := SetUp.Get("Hotkey")
			showArb := ObjBindMethod(this, "ShowAliasRunBox")
			if (TapTap.hotkey and hotkey_ != TapTap.hotkey) {
				Hotkey(TapTap.hotkey, showArb, "Off")
			}
			if (!TapTap.hotkey or hotkey_ != TapTap.hotkey) {
				Hotkey(hotkey_, showArb, "On")
				TapTap.hotkey := hotkey_
			}

			; if (SetUp.dict and SetUp.newDict and SetUp.dict["Hotkey"] != SetUp.newDict["Hotkey"]) {
			; 	Hotkey(SetUp.dict["Hotkey"], ShowAliasRunBox, "Off")
			; } else if (!SetUp.dict or (SetUp.newDict and SetUp.dict["Hotkey"] != SetUp.newDict["Hotkey"])) {
			; 	Hotkey(SetUp.newDict["Hotkey"], ShowAliasRunBox, "On")
			; }
			; if (SetUp.newDict) {
			; 	SetUp.dict := SetUp.newDict
			; 	SetUp.newDict := ""
			; }
		} catch Error as e {
			MsgBox(e.Message, "핫키 설정 에러", 16)
			ExitApp
		}
		; Hotkey(SetUp.dict["Hotkey"], ShowAliasRunBox, "On")
	}

	; FileInstall Bug : Source File이 %A_WorkingDir% 이외의 곳에 있으면,
	; 절대 경로, 상대 경로 전부 안 먹음.
	CopyInitFiles() {
		; 필수 파일
		destFile := A_WorkingDir . "\Lib\_SetUp\AutoHotkey.exe"
		if !FileExist(destFile)  {
			FileInstall("AutoHotkey.v1.1.33.10_U64.bin", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\_SetUp\TapTap.ini"
		if !FileExist(destFile) {
			FileInstall("TapTap.ini.Default", destFile, 0)
		}
		; 예제 파일
		destFile := A_WorkingDir . "\Lib\AHK\ShortCut_1.ahk"
		if !FileExist(destFile) {
			FileInstall("ShortCut_1.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\ShortCut_Etc.ahk"
		if !FileExist(destFile) {
			FileInstall("ShortCut_Etc.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\ShortCut_Help.ahk"
		if !FileExist(destFile) {
			FileInstall("ShortCut_Help.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\ScreenSaver.ahk"
		if !FileExist(destFile) {
			FileInstall("ScreenSaver.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\WifeWatch.ahk"
		if !FileExist(destFile) {
			FileInstall("WifeWatch.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\TapTap_Boot.ahk"
		if !FileExist(destFile) {
			FileInstall("TapTap_Boot.ahk.Org", destFile, 0)
		}
		destFile := A_WorkingDir . "\Lib\AHK\HelloWorld.py"
		if !FileExist(destFile) {
			FileInstall("HelloWorld.py", destFile, 0)
		}
		; 소스 파일
		; destFile := A_WorkingDir . "\Src.zip"
		; if !FileExist(destFile) {
		; 	FileInstall("Src.zip", destFile, 0)
		; }
		; TapTap.ahk
		; TapTap.ico
		; AliasList.ahk
		; Alias.ahk
		; SetUp.ahk
		; README.md
	}

	CreateFolder(folder) {
		if !FileExist(folder) {
			DirCreate(folder)
		}
	}
}
