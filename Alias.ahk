class Alias {
	static lowerCase := "abcdefghijklmnopqrstuvwxyz."

	QuitTapTap(_) {
		ExitApp
	}

	ReloadTapTap(_) {
		Reload
	}

	EditIniFile(option) {
		editor := SetUp.Get("Editor")
		static options := ["AliasList", "Ini"]
		static builtIns := ["EditAliasListIni", "EditTapTapIni"]
		iniFile := ""
		builtInFunc := builtIns[1]

		if (StrLen(option) = 1) {
			for index, value in options {
				if InStr(value, option, true) {
					builtInFunc := ObjBindMethod(this, builtIns[index])
					break
				}
			}
		} else {
			for index, value in options {
				if InStr(value, option) {
					builtInFunc := ObjBindMethod(this, builtIns[index])
					break
				}
			}
		}

		return builtInFunc()
	}

	EditTapTapIni(_) {
		editor := SetUp.Get("Editor")
		tapTapIniFile := SetUp.GetFilePath("IniFile")
		RunWait(editor . " " . tapTapIniFile)
		return "IniChanged"
	}

	EditAliasListIni(_) {
		editor := SetUp.Get("Editor")
		aliasListIniFile := SetUp.GetFilePath("AliasListIniFile")
		Run(editor . " " . AliasListIniFile)
		return ""
	}

	Run(option) {
		alias_ := this.aliases[1]
		aliasType := this.aliasType
		command := this.command
		defaultOption := this.option
		workingDir := this.workingDir
		res := ""
		if (aliasType != "BuiltIn" and StrLen(command) > 4) {	; *.ahk *.py 처리
			if (SubStr(command, StrLen(command) - 3) = ".ahk") {
				autoHotkey := SetUp.GetFilePath("AutoHotkey")
				ahkFile := SetUp.GetAhkFilePath(command)
				command := autoHotkey . " /CP65001 " . ahkFile
			} else if SubStr(command, StrLen(command) - 2 = ".py") {
				command := SetUp.GetPythonFilePath(command)
			}
		}
		try {
			if (aliasType = "BuiltIn") {
				builtInFunc := ObjBindMethod(this, command)
				res := aliasType . ", " . builtInFunc(option)
			} else if (aliasType = "ShortCut") {
				Run(command . " " . defaultOption, workingDir)
				res := aliasType
			} else if (aliasType = "Etc") {
				Run(command . " " . option . " " . defaultOption, workingDir)
				res := aliasType
			} else {
				Run(command . " " . option . " " . defaultOption, workingDir)
				res := aliasType . ", Ok"
			}
			; if (aliasType = "Run") {
			; 	Run, % command " " option, % workingDir
			; } else if (aliasType = "NewRun") {
			; 	Run, % command " " option, % workingDir
			; } else if (aliasType = "Script") {

			; } else if (aliasType = "Folder") {

			; } else if (aliasType = "Site") {

			; } else if (aliasType = "Etc") {

			; }
			return res
		} catch Error as e {
			msg := "명령어 타입: " . aliasType . "`n"
			msg .= "명령어: " . command . "`n"
			msg .= "옵션: " . option . defaultOption . "`n"
			msg .= "작업 폴더: " . workingDir . "`n"
			msg .= e.Message
			MsgBox(msg, "명령어 실행 실패", 16)
			return "Error"
		}
	}

	CheckAlias(alias_) {
		; 즉각 실행 명령
		if (!alias_ and StrLen(alias_) = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_) {	; CaseSensitive
			return "ImmediateRun"
		}
		; if ((this.aliasType = "ShortCut" or this.aliasType = "BuiltIn") and alias_ != "") {
		; 	if (StrLen(alias_) = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_)	; CaseSensitive
		; 		return "ImmediateRun"
		; }

		aliasIndex := 0
		For index, value in this.Aliases
		{
			if (alias_ = "") {
				pos := 1
			} else {
				pos := InStr(value, alias_)	; alias가 "" 이면, 항상 1 반환
			}
			if (pos != 0 and (aliasIndex = 0 || pos < aliasIndex))
				aliasIndex := pos
			if (pos = 1)
				break
		}
		return aliasIndex
	}

	GetAliasesString() {
		return this.GetStringFromArray(this.aliases)
	}

	GetSubMenuString() {
		return this.GetStringFromArray(this.subMenu)
	}

	GetSubIndexString() {
		return this.GetStringFromArray(this.subIndex)
	}

	GetArrayFromString(str) {
		array_ := []
		outArray := StrSplit(str, ",")
		For index, value in outArray
		{
			elem := Trim(value)
			array_.push(elem)
		}
		return array_
	}

	GetStringFromArray(array_) {
		str := ""
		For index, value in array_
		{
			if (str = "")
				str := value
			else if (value != "")
					str := str . ", " . value
		}
		return str
	}

	__New(aliasType, aliasLine, typeLine) {
		this.aliasType := aliasType
		this.aliases := this.GetArrayFromString(aliasLine)

		typeArray := this.GetArrayFromString(typeLine)
		if (typeArray.Length) {
			this.command := Trim(typeArray.RemoveAt(1))
		} else {
			this.command := ""
		}
		if (typeArray.Length) {
			this.option := Trim(typeArray.RemoveAt(1))
		} else {
			this.option := ""
		}
		if (typeArray.Length) {
			this.workingDir := Trim(typeArray.RemoveAt(1))
		} else {
			this.workingDir := ""
		}
		if (typeArray.Length) {
			this.winTitle := Trim(typeArray.RemoveAt(1))
		} else {
			this.winTitle := ""
		}

		; if (this.workingDir or this.winTitle) {
		; 	msg := "AliasType: " . this.AliasType
		; 	msg .= "`n" . "Alias: " . this.GetStringFromArray(this.aliases)
		; 	msg .= "`n" . "Command: " . this.command
		; 	msg .= "`n" . "Option: " . this.option
		; 	msg .= "`n" . "Working Dir: " . this.workingDir
		; 	msg .= "`n" . "Window Title: " . this.winTitle
		; 	MsgBox, %msg%
		; }
	}
	i_New(comment:="", aliases:="", aliasType:="", command :="", option:= "", workingDir:="", showCmd:="", winTitle:="", mainMenu:= "", mainIndex:="", subMenu:="", subIndex:="") {
		this.comment := comment
		this.aliases := this.GetArrayFromString(aliases)
		this.aliasType := aliasType
		this.command := command
		this.option := option
		this.workingDir := workingDir
		this.showCmd := showCmd
		this.winTitle := winTitle
		this.mainMenu := mainMenu
		this.mainIndex := mainIndex
		this.subMenu := this.GetArrayFromString(subMenu)
		this.subIndex := this.GetArrayFromString(subIndex)
	}
}
