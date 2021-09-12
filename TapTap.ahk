#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
#Persistent
FileEncoding, UTF-8-RAW

global T_ArbEdit := ""
global T_ArbList := ""
global T_ArbEnter := ""
global T_AliasList := ""
global T_SetUp := ""
global T_Hotkey := ""
global T_TapTapTitle := "ARB_TapTap"
global T_ActiveWinowTitleOnArb := ""
global T_IsArbShowing := false
global T_IsInputHighLighting := false

InitTapTap()
CreateARB()
return

; CapsLock 키 변경 to LControl by KeyTweak
; CapsLock Toggle 키 (CapsLock + 우측 Shift)
>+LControl::
SetCapsLockState % !GetKeyState("CapsLock", "T")
return

; 프로그램 함수
ShowAliasRunBox() {
	if (T_IsArbShowing)
		return
	if IsHotkeyChanged() {
		ResetHotkey()
		return
	}
	If (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 350)
		ShowARB()
}

ARBGuiClose() {
	MsgBox, ARB Closed Check!
}

HideARB() {
	SetTimer, EscapeArbTimer, off
	Gui, ARB:Hide
}

ARBGuiEscape() {
	HideARB()
	global T_IsArbShowing := false
	WinActivate , %T_ActiveWinowTitleOnArb%
}

TabProcessTimer() {
	previousAlias := T_AliasList.previousAlias
	; GuiControl, , Edit1, % previousAlias	; 안 먹힘
	; ControlSend, Edit1, {Enter}, % T_TapTapTitle
	ControlSend, Edit1, {BackSpace}%previousAlias%{Enter}, % T_TapTapTitle
}

TabDeleteTimer() {
	ControlSend, Edit1, {Backspace}{Enter}, % T_TapTapTitle
}

SpaceProcessTimer() {
	previousAlias := T_AliasList.previousAlias
	; GuiControl, , Edit1, % previousAlias	; 안 먹힘
	ControlSend, Edit1, {End}{Space}, % T_TapTapTitle
}

ARBGuiEditHandler() {
	global T_IsInputHighLighting
	Gui, Submit, NoHide
	arbEdit := T_ArbEdit

	; 입력란 하이라이트, Tab, Space 처리
	if (T_IsInputHighLighting) {
		T_IsInputHighLighting := false
		previousAlias := T_AliasList.previousAlias
		if InStr(arbEdit, A_Space) {
  			GuiControl, , Edit1, % previousAlias
			SetTimer, SpaceProcessTimer, -1
			return
		}

		if InStr(arbEdit, A_Tab) {
			; GuiControl, , Edit1, % previousAlias
			SetTimer, TabProcessTimer, -1
			return
		}
	} else if InStr(arbEdit, A_Tab) {
		SetTimer, TabDeleteTimer, -1
		return
	}
	; 명령어 옵션을 입력하는 경우를 제외하고, 리스트 Update
	if (StrLen(arbEdit) = 1 or InStr(arbEdit, " ") = 0)
		UpdateListView(arbEdit)
}

ARBGuiEnterPressed() {
	Gui, Submit, NoHide
	arbEdit := T_ArbEdit
	HideARB()	; ARB 화면 죽인 후, 명령 실행
	T_AliasList.RunAlias(arbEdit)
	ARBGuiEscape()
}

ImmediateRunTimer() {
	ControlSend, Edit1, {Enter}, % T_TapTapTitle
}

UpdateListView(alias_) {
	list := T_AliasList.ListAlias(alias_)
	length := list.Length()
	if (length = 0) {
		GuiControl, -Redraw, T_ArbList
		LV_Delete()
		GuiControl, +Redraw, T_ArbList
		return
	}
	if (length = 1 and list[1] = "ImmediateRun") {
		SetTimer, ImmediateRunTimer, -1
		return
	}
	GuiControl, -Redraw, T_ArbList
	LV_Delete()
	For index, val in list
	{
		;LV_Insert(1, , val)
		LV_Add(, val)
	}
	LV_Modify(1, "Select")
	GuiControl, +Redraw, T_ArbList
}

PreviousAliasSendTimer() {
	previousAlias := T_AliasList.previousAlias
	if (previousAlias = "") {
		ControlSend, Edit1, ^a{Space}{BackSpace}, % T_TapTapTitle
	} else {
		ControlSend, Edit1, ^a%previousAlias%^a, % T_TapTapTitle
		T_IsInputHighLighting := true
	}
}

ShowARB() {
    global T_IsArbShowing := true

	global T_ActiveWinowTitleOnArb
	WinGetActiveTitle, T_ActiveWinowTitleOnArb

	CoordMode, Mouse, Screen
	MouseGetPos, mouseX, mouseY
	posX := mouseX
	posY := mouseY
	if (A_ScreenWidth < mouseX + 410)
		posX := A_ScreenWidth - 410
	if (A_ScreenHeight < mouseY + 220)
		posY := A_ScreenHeight - 220
	Gui, ARB:Show, X%posX% Y%posY%

	mouseX := posX + 100
	mouseY := posY + 15
	MouseMove, mouseX, mouseY

	; SetTimer, PreviousAliasSendTimer, -10
	previousAlias := T_AliasList.previousAlias
	if (previousAlias = "") {
		ControlSend, Edit1, ^a{Space}{BackSpace}, % T_TapTapTitle
	} else {
		ControlSend, Edit1, ^a%previousAlias%^a, % T_TapTapTitle
		T_IsInputHighLighting := true
	}

	SetTimer, EscapeArbTimer, 1000
}

EscapeArbTimer() {
	if WinActive(T_TapTapTitle) {
		return
	}

	global T_ActiveWinowTitleOnArb
	WinGetActiveTitle, T_ActiveWinowTitleOnArb

	ControlSend, Edit1, {Escape}, % T_TapTapTitle
}

CreateARB() {
	Gui, ARB:New, +AlwaysOnTop -Caption +ToolWindow, % T_TapTapTitle
	Gui, ARB:Font, S18 W1000, 나눔고딕
	Gui, ARB:Margin, 1, 1
	Gui, ARB:Add, Edit, w320 r1 WantTab vT_ArbEdit gARBGuiEditHandler

	Gui, ARB:Font, S12 W800, 나눔고딕
	Gui, ARB:Margin, 1, 1
	Gui, ARB:Add, ListView, R6 wp -Hdr ReadOnly vT_ArbList, 1
	Gui, ARB:Add, Button, x-10 y-10 w1 h1 +default Hidden vT_ArbEnter gARBGuiEnterPressed	; Default Button Hidden
}

InitTapTap() {
	CreateFolder(A_WorkingDir . "\Lib")
	CreateFolder(A_WorkingDir . "\Lib\AHK")
	CreateFolder(A_WorkingDir . "\Lib\Python")

	; dest := A_WorkingDir . "\Lib\TapTap.AliasList"
	; FileInstall, TapTap.AliasList.Org, %dest%
	; dest := A_WorkingDir . "\Lib\AHK\Hotkey_Help.ahk"
	; FileInstall, Hotkey_Help.ahk, %dest%
	; dest := A_WorkingDir . "\Lib\AHK\Hotkey_1.ahk"
	; FileInstall, Hotkey_1.ahk, %dest%
	; dest := A_WorkingDir . "\Lib\AHK\ScreenSaver.ahk"
	; FileInstall, ScreenSaver.ahk, %dest%
	; dest := A_WorkingDir . "\Lib\AHK\Watch.ahk"
	; FileInstall, Watch.ahk, %dest%

	global T_AliasList := new AliasList()
	T_AliasList.RunOnBoot()

	; 탭탭이(TapTap) ARB 기동 용 핫키 지정
	SetHotkey()
}

IsHotkeyChanged() {
	if (T_Hotkey != "" and T_Hotkey != T_SetUp.GetValue("Hotkey"))
		return true
	else
		return false
}

ResetHotkey() {
	global T_Hotkey
	Hotkey, %T_Hotkey%, ShowAliasRunBox, Off
	global T_Hotkey := T_SetUp.GetValue("Hotkey")
	Hotkey, %T_Hotkey%, ShowAliasRunBox
}

SetHotkey() {
	global T_SetUp := new SetUp()
	global T_Hotkey := T_SetUp.GetValue("Hotkey")
	Hotkey, %T_Hotkey%, ShowAliasRunBox
}

CreateFolder(folder) {
	if !FileExist(folder) {
		FileCreateDir, %folder%
	}
}

#Include, AliasList.ahk
#Include, SetUp.ahk
