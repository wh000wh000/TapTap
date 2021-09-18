#Include "SetUp.ahk"
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
		tapTapIniFile := SetUp.iniFile
		RunWait(editor . " " . tapTapIniFile)
		SetUp.isIniChanged := true
		return "Ok, IniChanged"
	}

	EditAliasListIni(_) {
		editor := SetUp.Get("Editor")
		aliasListIniFile := SetUp.GetFilePath("AliasList")
		Run(editor . " " . AliasListIniFile)
		return "Ok"
	}

	Run(option) {
		aliasType := this.aliasType
		command := this.command
		defaultOption := this.option
		workingDir := this.workingDir
		res := aliasType
		pid := ""
		try {
			switch aliasType {
				case "Run", "NewReun", "Site":
					Run(command . " " . option . defaultOption, workingDir, &pid)
				case "Script":
					if (StrLen(command) > 4 and SubStr(command, StrLen(command) - 3) = ".ahk") {
						autoHotkey := SetUp.GetFilePath("AutoHotkeyExe")
						ahkFile := SetUp.GetScriptPath(command)
						command := autoHotkey . " /CP65001 " . ahkFile
					} else if (StrLen(command) > 3 and SubStr(command, StrLen(command) - 2) = ".py") {
						command := SetUp.GetScriptPath(command)
					}
					Run(command . " " . option . defaultOption, workingDir, &pid)
				case "BuiltIn":
					builtInFunc := ObjBindMethod(this, command)
					res .= ", " . builtInFunc(option)
				case "Folder":
					Run("Explorer " . command . option . defaultOption, , &pid)
				default:	; Etc
					Run(command . " " . option . " " . defaultOption, workingDir, &pid)
			}
			if (pid)
				WinWaitActive("ahk_pid " . pid)
			return [res . ", Ok", pid]
		} catch Error as e {
			msg := "명령어 타입: " . aliasType . "`n"
			msg .= "명령어: " . command . "`n"
			msg .= "옵션: " . option . defaultOption . "`n"
			msg .= "작업 폴더: " . workingDir . "`n"
			msg .= e.Message
			MsgBox(msg, "명령어 실행 에러", 16)
			return [res . ", Error", ""]
		}
	}

	CheckAlias(alias_) {
		; 단축키: 즉각 실행 명령
		aliasLen := StrLen(alias_)
		if (alias_ and aliasLen = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_) {	; CaseSensitive
			return "ShortCut"
		}

		; 첫 별칭에서 처음부터 일치하는 경우: 1
		; 2번째 이후 별칭에서 처음부터 일치하는 경우: 2
		; 중간의 대문자가 일치하는 경우: 3
		; 아무 곳이나 일치하는 경우: 4
		; 일치하는 곳이 없는 경우: 5
		aliasIndex := 5
		For index, value in this.Aliases
		{
			if (aliasLen = 0) {
				return 1
			} else {
				pos := InStr(value, alias_)
				if (pos = 1) {
					if (index = 1) {
						return 1
					} else {
						return 2
					}
				}
				; [옵션1 옵션2] "[" 제거
				if (pos > 1 and InStr(SubStr(value, 1, pos - 1), "[")) {
					continue
				}
				ch := SubStr(alias_, aliasLen)
				if (!InStr(Alias.lowerCase, ch, true) and aliasLen > 1) {
					; 중간 대문자 찾기
					p := Instr(value, SubStr(alias_, 1, aliasLen - 1))
					toSeek := p + aliasLen - 1
					chPos := InStr(SubStr(value, toSeek), ch, true)
					if ((p and StrLen(value) >= toSeek) and chPos) {
						; [옵션1 옵션2] "[" 제거
						if !InStr(SubStr(value, 1, toSeek + chPos -1), "[")
							aliasIndex := 3
					}
				}
				if (pos and aliasIndex = 5) {
					aliasIndex := 4
				}
			}
		}
		return aliasIndex
	}

	GetAliasesString() {
		return this.GetStringFromArray(this.aliases)
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
			else
				str := str . ", " . value
		}
		return str
	}

	GetCommandString() {
		arr := []
		arr.Push(this.command)
		arr.Push(this.Option)
		arr.Push(this.workingDir)
		arr.Push(this.winTitle)
		str := Trim(this.GetStringFromArray(arr))
		Loop 4
		{
			if (SubStr(str, StrLen(str), 1) = ",") {
				str := Trim(SubStr(str, 1, Strlen(str) - 1))
			} else {
				break
			}
		}
		return str
	}

	__New(aliasType, aliasesLine, commandLine) {
		this.aliasType := aliasType
		this.aliases := this.GetArrayFromString(aliasesLine)

		typeArray := this.GetArrayFromString(commandLine)
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
