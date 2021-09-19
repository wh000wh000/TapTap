﻿#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
Persistent
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
FileEncoding("UTF-8")

#Include "SetUp.ahk"
#Include "AliasList.ahk"
TapTap()
; CapsLock 키 변경 to LControl by KeyTweak
; CapsLock Toggle 키 (CapsLock + 우측 Shift)
>+LControl::
{
	SetCapsLockState(!GetKeyState("CapsLock", "T"))
}

class TapTap {
	static arb := ""
	static arbEdit := ""
	static arbList := ""
	static arbEnter := ""
	static hotkey := ""
	static title := "ARB_TapTap"
	static isArbShowing := false
	static isInputHighLighting := false
	static isIniChanged := false
	static activeWindow := ""

	__New() {
		;@Ahk2Exe-SetMainIcon TapTap.ico
		if (!A_IsCompiled)
			TraySetIcon("TapTap.ico")	; TapTap Icon
		this.InitTapTap()
		this.CreateARB()
	}

	; 프로그램 함수
	ShowAliasRunBox(_) {
		if (TapTap.isArbShowing)
			return

		tapTap_ := SetUp.Get("TapTap")
		hotkeyTime := SetUp.Get("TapTapSpeed")

		If (tapTap_ and A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < SetUp.Get("TapTapSpeed")) {
			this.ShowARB()
		} else if (!tapTap_) {
			this.ShowARB()
		}
	}

	HideARB() {
		timer := ObjBindMethod(this, "ArbEscapeTimer")
		SetTimer(timer, 0)
		TapTap.arb.Hide()
		TapTap.isArbShowing := false
	}

	ArbEscapePressed(_) {
		this.HideARB()

		this.RestoreActiveWindow()
	}

	RestoreActiveWindow() {
		activeWin := "ahk_id " . TapTap.activeWindow
		WinActivate(activeWin)
		WinWaitActive(activeWin)
	}

	TabProcessTimer() {
		previousAlias := AliasList.previousAlias
		ControlSend("{BackSpace}" . previousAlias . "{Enter}", "Edit1", TapTap.arb)
	}

	SpaceProcessTimer() {
		previousAlias := AliasList.previousAlias
		ControlSend("{End}{Space}", "Edit1", TapTap.arb)
	}

	ArbEditChanged(ab, _) {
		TapTap.arb.Submit(false)
		arbEdit := TapTap.arbEdit.value

		; 입력란 하이라이트, Tab, Space 처리
		if (TapTap.isInputHighLighting) {
			TapTap.isInputHighLighting := false
			if InStr(arbEdit, A_Space) {
				TapTap.arbEdit.Value := AliasList.previousAlias
				timer := ObjBindMethod(this, "SpaceProcessTimer")
				SetTimer(timer, -100)
				return
			}

			if InStr(arbEdit, A_Tab) {
				; GuiControl, , Edit1, % AliasList.previousAlias
				timer := ObjBindMethod(this, "TabProcessTimer")
				SetTimer(timer, -100)
				return
			}
		} else if InStr(arbEdit, A_Tab) {
			SetTimer(() => ControlSend("{Backspace}{Enter}", "Edit1", TapTap.arb), -100)
			return
		}
		; 명령어 옵션을 입력하는 경우를 제외하고, 리스트 Update
		; if (StrLen(arbEdit) = 1 or InStr(arbEdit, " ") = 0)
			this.UpdateListView(arbEdit)
	}

	ArbEnterPressed(abc, i) {
		this.HideARB()	; ARB 화면 죽인 후, 명령 실행
		TapTap.arb.Submit()
		arbEdit := TapTap.arbEdit.value
		res := AliasList.RunAlias(arbEdit)
		if InStr(res[1], "Error") {
			this.RestoreActiveWindow()
		} else if InStr(res[1], "IniChanged") {
			this.SetHotkey()
			TapTap.isIniChanged := true
		}
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
		if (length = 1 and list[1] = "ShortCut") {
			SetTimer(() => ControlSend("{Enter}", "Edit1", TapTap.arb), -100)
			return
		}
		TapTap.arbList.Opt("-Redraw")
		TapTap.arbList.Delete()
		For index, val in list
		{
			TapTap.arbList.Add(, val)
		}
		TapTap.arbList.Modify(1, "Select")
		TapTap.arbList.Opt("+Redraw")
	}

	PreviousAliasSendTimer() {
		if (AliasList.previousAlias = "") {
			ControlSend("^a{Space}{BackSpace}", "Edit1", TapTap.arb)
		} else {
			ControlSend("^a" . AliasList.previousAlias . "^a", "Edit1", TapTap.arb)
			TapTap.isInputHighLighting := true
		}
	}

	ShowARB() {
		TapTap.isArbShowing := true
		TapTap.activeWindow := WinExist("A")

		if (TapTap.isIniChanged) {
			TapTap.arb.Destroy()
			this.CreateARB()
			TapTap.isIniChanged := false
		}

		CoordMode("Mouse", "Screen")
		MouseGetPos(&mouseX, &mouseY)
		posX := mouseX
		posY := mouseY
		moveX := SetUp.Get("ArbMoveX")
		moveY := SetUp.Get("ArbMoveY")
		if (A_ScreenWidth < mouseX + moveX)
			posX := A_ScreenWidth - moveX
		if (A_ScreenHeight < mouseY + moveY)
			posY := A_ScreenHeight - moveY
		TapTap.arb.Show("X" . posX . " Y" . posY)

		mouseX := posX + 100
		mouseY := posY + 15
		MouseMove(mouseX, mouseY)

		previousAlias := AliasList.previousAlias
		if (previousAlias = "") {
			ControlSend("^a{Space}{BackSpace}", "Edit1", TapTap.arb)
		} else {
			ControlSend("^a" . previousAlias . "^a", "Edit1", TapTap.arb)
			TapTap.isInputHighLighting := true
		}

		timer := ObjBindMethod(this, "ArbEscapeTimer")
		; SetTimer(timer, -1000)
	}

	ArbEscapeTimer() {
		if WinActive(TapTap.arb) {
			timer := ObjBindMethod(this, "ArbEscapeTimer")
			SetTimer(timer, -1000)
			return
		} else if (!TapTap.isArbShowing) {
			return
		}

		activeWin := WinExist("A")
		TapTap.activeWindow := activeWin

		ControlSend("{Escape}", "Edit1", TapTap.arb)
	}

	CreateARB() {
		TapTap.arb := Gui("+AlwaysOnTop -Caption +ToolWindow", TapTap.title)
		TapTap.arb.SetFont(SetUp.Get("ArbEditFontSize") . " " . SetUp.Get("ArbEditFontWeight"), SetUp.Get("ArbEditFont"))
		TapTap.arb.MarginX := "1", TapTap.arb.MarginY := "1"
		TapTap.arbEdit := TapTap.arb.Add("Edit", "w" . SetUp.Get("ArbWidth") . " r1 WantTab")
		editHandler := ObjBindMethod(this, "ArbEditChanged")
		TapTap.arbEdit.OnEvent("Change", editHandler)

		TapTap.arb.SetFont(SetUp.Get("ArbListFontSize") . " " . SetUp.Get("ArbListFontWeight"), SetUp.Get("ArbListFont"))
		TapTap.arb.MarginX := "1", TapTap.arb.MarginY := "1"
		TapTap.arbList := TapTap.arb.Add("ListView", "R" . SetUp.Get("ArbListRows") . " wp -Hdr ReadOnly", ["1"])
		TapTap.arbEnter := TapTap.arb.Add("Button", "x-10 y-10 w1 h1 +default Hidden")
		enterHandler := ObjBindMethod(this, "ArbEnterPressed")
		TapTap.arbEnter.OnEvent("Click", enterHandler)	; Default Button Hidden
		escapeHandler := ObjBindMethod(this, "ArbEscapePressed")
		TapTap.arb.OnEvent("Escape", escapeHandler)
	}

	InitTapTap() {
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
		} catch Error as e {
			MsgBox(e.Message, "핫키 설정 에러", 16)
			ExitApp
		}
	}

	; FileInstall Bug : Source File이 %A_WorkingDir% 이외의 곳에 있으면,
	; 절대 경로, 상대 경로 전부 안 먹힘 => AHK v2 로 해결
	CopyInitFiles() {
		; 예제 파일
		if FileExist(A_WorkingDir . "\Lib\AHK") {
			destFile := A_WorkingDir . "\Lib\AHK\ShortCut_1.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\ShortCut_1.ahk.Org", destFile, 0)
			}
			destFile := A_WorkingDir . "\Lib\AHK\ShortCut_Etc.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\ShortCut_Etc.ahk.Org", destFile, 0)
			}
			destFile := A_WorkingDir . "\Lib\AHK\ShortCut_Help.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\ShortCut_Help.ahk.Org", destFile, 0)
			}
			destFile := A_WorkingDir . "\Lib\AHK\ScreenSaver.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\ScreenSaver.ahk.Org", destFile, 0)
			}
			destFile := A_WorkingDir . "\Lib\AHK\WifeWatch.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\WifeWatch.ahk.Org", destFile, 0)
			}
			destFile := A_WorkingDir . "\Lib\AHK\TapTap_Boot.ahk"
			if !FileExist(destFile) {
				FileInstall("Src\TapTap_Boot.ahk.Org", destFile, 0)
			}
		}
		if FileExist(A_WorkingDir . "\Lib\Python") {
			destFile := A_WorkingDir . "\Lib\Python\HelloWorld.py"
			if !FileExist(destFile) {
				FileInstall("Src\HelloWorld.py", destFile, 0)
			}
		}
	}
}
