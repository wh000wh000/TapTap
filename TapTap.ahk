#Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
#SingleInstance Force
Persistent
FileEncoding("UTF-8")

#Include "SetUp.ahk"
#Include "AliasList.ahk"

global T_Arb := ""
global T_ArbEdit := ""
global T_ArbList := ""
global T_ArbEnter := ""
global T_AliasList := ""
; global T_SetUp := ""
global T_Hotkey := ""
global T_TapTapTitle := "ARB_TapTap"
global T_ActiveWindowOnArb := ""
global T_IsArbShowing := false
global T_IsInputHighLighting := false

;@Ahk2Exe-SetMainIcon TapTap.ico
if (!A_IsCompiled)
	TraySetIcon("TapTap.ico")	; TapTap Icon

InitTapTap()
CreateARB()
return

; CapsLock 키 변경 to LControl by KeyTweak
; CapsLock Toggle 키 (CapsLock + 우측 Shift)
>+LControl::
{ ; V1toV2: Added bracket
SetCapsLockState(!GetKeyState("CapsLock", "T"))
}

; 프로그램 함수
; Added bracket before function
ShowAliasRunBox(_) {
	if (T_IsArbShowing)
		return
	If (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 350)
		ShowARB()
}

ARBGuiClose() {
	MsgBox("ARB Closed Check!")
}

HideARB() {
	SetTimer(EscapeArbTimer, 0)
	; ARB := Gui()
	T_Arb.Hide()
}

ARBGuiEscape(_) {
	HideARB()
	global T_IsArbShowing := false

	SetTitleMatchMode(2)
	WinActivate(T_ActiveWindowOnArb)
}

TabProcessTimer() {
	previousAlias := AliasList.previousAlias
	; GuiControl, , Edit1, % previousAlias	; 안 먹힘
	; ControlSend, Edit1, {Enter}, % T_TapTapTitle
	ControlSend("{BackSpace}" . previousAlias . "{Enter}", "Edit1", T_TapTapTitle)
}

TabDeleteTimer() {
	ControlSend("{Backspace}{Enter}", "Edit1", T_TapTapTitle)
}

SpaceProcessTimer() {
	previousAlias := AliasList.previousAlias
	; GuiControl, , Edit1, % previousAlias	; 안 먹힘
	ControlSend("{End}{Space}", "Edit1", T_TapTapTitle)
}

ARBGuiEditHandler(ab, _) {
	global T_IsInputHighLighting, T_Arb
	oSaved := T_Arb.Submit(false)
	arbEdit := T_ArbEdit.value

	; 입력란 하이라이트, Tab, Space 처리
	if (T_IsInputHighLighting) {
		T_IsInputHighLighting := false
		previousAlias := AliasList.previousAlias
		if InStr(arbEdit, A_Space) {
  			T_ArbEdit.Value := previousAlias
			SetTimer(SpaceProcessTimer, -20)
			return
		}

		if InStr(arbEdit, A_Tab) {
			; GuiControl, , Edit1, % previousAlias
			SetTimer(TabProcessTimer, -20)
			return
		}
	} else if InStr(arbEdit, A_Tab) {
		SetTimer(TabDeleteTimer, -20)
		return
	}
	; 명령어 옵션을 입력하는 경우를 제외하고, 리스트 Update
	if (StrLen(arbEdit) = 1 or InStr(arbEdit, " ") = 0)
		UpdateListView(arbEdit)
}

ARBGuiEnterPressed(abc, i) {
	global T_Arb
	oSaved := T_Arb.Submit(false)
	arbEdit := T_ArbEdit.value
	HideARB()	; ARB 화면 죽인 후, 명령 실행
	res := T_AliasList.RunAlias(arbEdit)
	ARBGuiEscape("_")
	if InStr(res, "IniChanged") {
		SetHotkey()
	}
}

ImmediateRunTimer() {
	ControlSend("{Enter}", "Edit1", T_TapTapTitle)
}

UpdateListView(alias_) {
	list := T_AliasList.ListAlias(alias_)
	length := list.Length
	if (length = 0) {
		T_ArbList.Opt("-Redraw")
		T_ArbList.Delete()
		T_ArbList.Opt("+Redraw")
		return
	}
	if (length = 1 and list[1] = "ImmediateRun") {
		SetTimer(ImmediateRunTimer, -20)
		return
	}
	T_ArbList.Opt("-Redraw")
	T_ArbList.Delete()
	For index, val in list
	{
		;LV_Insert(1, , val)
		T_ArbList.Add(, val)
	}
	T_ArbList.Modify(1, "Select")
	T_ArbList.Opt("+Redraw")
}

PreviousAliasSendTimer() {
	previousAlias := AliasList.previousAlias
	if (previousAlias = "") {
		ControlSend("^a{Space}{BackSpace}", "Edit1", T_TapTapTitle)
	} else {
		ControlSend("^a" . previousAlias . "^a", "Edit1", T_TapTapTitle)
		global T_IsInputHighLighting := true
	}
}

ShowARB() {
	global T_AliasList
    global T_IsArbShowing := true

	SaveActiveWindow()

	CoordMode("Mouse", "Screen")
	MouseGetPos(&mouseX, &mouseY)
	posX := mouseX
	posY := mouseY
	if (A_ScreenWidth < mouseX + 410)
		posX := A_ScreenWidth - 410
	if (A_ScreenHeight < mouseY + 220)
		posY := A_ScreenHeight - 220
	T_Arb.Show("X" . posX . " Y" . posY)

	mouseX := posX + 100
	mouseY := posY + 15
	MouseMove(mouseX, mouseY)

	; SetTimer, PreviousAliasSendTimer, -10
	; previousAlias := T_AliasList.previousAlias
	previousAlias := AliasList.previousAlias
	if (previousAlias = "") {
		ControlSend("^a{Space}{BackSpace}", "Edit1", T_TapTapTitle)
	} else {
		ControlSend("^a" . previousAlias . "^a", "Edit1", T_TapTapTitle)
		global T_IsInputHighLighting := true
	}

	; SetTimer(EscapeArbTimer,1000)
}

SaveActiveWindow() {
	global T_ActiveWindowOnArb
	T_ActiveWindowOnArb := WinExist("A")
	if (!T_ActiveWindowOnArb) {
		MouseGetPos( , , &T_ActiveWindowOnArb)
	}
}

EscapeArbTimer() {
	if WinActive(T_TapTapTitle) {
		return
	}

	SaveActiveWindow()

	ControlSend("{Escape}", "Edit1", T_TapTapTitle)
}
T_ArbEdit_Click(abc, info) {
	a := T_ArbEdit.value
}
T_ArbEdit_Change(abc, info) {
	a := T_ArbEdit.value
}
Ctrl_Click(T_ArbEnter, info) {
	b := 3
}
CreateARB() {
	global T_Arb := Gui(, T_TapTapTitle)
	T_Arb.Opt("+AlwaysOnTop -Caption +ToolWindow")
	T_Arb.SetFont("S18 W1000", "나눔고딕")
	T_Arb.MarginX := "1", T_Arb.MarginY := "1"
	global T_ArbEdit := T_Arb.Add("Edit", "w320 r1 WantTab vT_ArbEdit")
	T_ArbEdit.OnEvent("Change", ARBGuiEditHandler)

	T_Arb.SetFont("S12 W800", "나눔고딕")
	T_Arb.MarginX := "1", T_Arb.MarginY := "1"
	global T_ArbList := T_Arb.Add("ListView", "R6 wp -Hdr ReadOnly vT_ArbList", ["1"])
	global T_ArbEnter := T_Arb.Add("Button", "x-10 y-10 w1 h1 +default Hidden vT_ArbEnter")
	T_ArbEnter.OnEvent("Click", ARBGuiEnterPressed)	; Default Button Hidden
	T_Arb.OnEvent("Escape", ARBGuiEscape)
}

InitTapTap() {
	CreateFolder(A_WorkingDir . "\Lib")
	CreateFolder(A_WorkingDir . "\Lib\_SetUp")
	CreateFolder(A_WorkingDir . "\Lib\AHK")
	CreateFolder(A_WorkingDir . "\Lib\Python")
	; CreateFolder(A_WorkingDir . "\Src")

	CopyInitFiles()

	SetHotkey()

	global T_AliasList := AliasList()
	T_AliasList.RunOnBoot()

	; 탭탭이(TapTap) ARB 기동 용 핫키 지정
	; SetHotkey()
}

SetHotkey() {
	try {
		global T_Hotkey
		hotkey_ := SetUp.Get("Hotkey")
		if (T_Hotkey and hotkey_ != T_Hotkey) {
			Hotkey(T_Hotkey, ShowAliasRunBox, "Off")
		}
		if (!T_Hotkey or hotkey_ != T_Hotkey) {
			Hotkey(hotkey_, ShowAliasRunBox, "On")
			T_Hotkey := hotkey_
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
