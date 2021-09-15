class Alias {
	static lowerCase := "abcdefghijklmnopqrstuvwxyz."
	static iniFiles := ["AliasList", "Ini"]
	static builtInFuncs := ["EditAliasListIni", "EditTapTapIni"]

	QuitTapTap(_) {
		ExitApp
	}

	ReloadTapTap(_) {
		Reload
	}

	GetOptionIndex(option, options) {
		if (!option) {
			return 1
		} else if (StrLen(option) = 1) {
			for index, value in options {
				if InStr(value, option, true) {
					return index
				}
			}
		} else {
			for index, value in options {
				if InStr(value, option) {
					return index
				}
			}
		}
	}

	EditIniFile(option) {
		fn := Alias.builtInFuncs[this.GetOptionIndex(option, Alias.iniFiles)]
		return ObjBindMethod(this, fn).Call("")
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
		try {
			switch aliasType {
				case "Run", "NewReun", "Site":
					Run(command . " " . option . defaultOption, workingDir)
					return "Ok"
				case "Script":
					if (StrLen(command) > 4 and SubStr(command, StrLen(command) - 3) = ".ahk") {
						autoHotkey := SetUp.GetFilePath("AutoHotkey")
						ahkFile := SetUp.GetAhkFilePath(command)
						command := autoHotkey . " /CP65001 " . ahkFile
					} else if (StrLen(command) > 3 and SubStr(command, StrLen(command) - 2) = ".py") {
						command := SetUp.GetPythonFilePath(command)
					}
					Run(command . " " . option . defaultOption, workingDir)
					return aliasType
				case "BuiltIn":
					builtInFunc := ObjBindMethod(this, command)
					return aliasType . ", " . builtInFunc(option)
				case "Folder":
					Run("Explorer " . command . option . defaultOption)
					return aliasType
				default:	; Etc
					Run(command . " " . option . " " . defaultOption, workingDir)
					return aliasType
			}
		} catch Error as e {
			msg := "명령어 타입: " . aliasType . "`n"
			msg .= "명령어: " . command . "`n"
			msg .= "옵션: " . option . defaultOption . "`n"
			msg .= "작업 폴더: " . workingDir . "`n"
			msg .= e.Message
			MsgBox(msg, "명령어 실행 에러", 16)
			return "Error"
		}
	}

	CheckAlias(alias_) {
		; 즉각 실행 명령
		if (alias_ and StrLen(alias_) = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_) {	; CaseSensitive
			return "ImmediateRun"
		}
		; if ((this.aliasType = "ShortCut" or this.aliasType = "BuiltIn") and alias_ != "") {
		; 	if (StrLen(alias_) = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_)	; CaseSensitive
		; 		return "ImmediateRun"
		; }

		; aliasIndex := 0
		; For index, value in this.Aliases
		; {
		; 	if (alias_ = "") {
		; 		pos := 1
		; 	} else {
		; 		pos := InStr(value, alias_)
		; 		if (pos != 0)
		; 		pos .= index
		; 	}
		; 	if (pos != 0 and (aliasIndex = 0 || pos < aliasIndex))
		; 		aliasIndex := pos
		; 	if (pos = 1)
		; 		break
		; }
		aliasIndex := "99"
		For index, value in this.Aliases
		{
			if (index = 10)
				break
			if (alias_ = "") {
				pos_ := "11"
			} else {
				pos := InStr(value, alias_)
				if (pos = 0) {
					pos_ := "9" . index
				} else {
					if (pos > 9)
						pos := 9
					pos_ := pos . "" . index
				}
			}
			if (aliasIndex = "99" || pos_ < aliasIndex)
				aliasIndex := pos_
			if (pos_ = "11")
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
}
