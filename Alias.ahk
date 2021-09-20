#Include "SetUp.ahk"
class Alias {
	static lowerCase := "abcdefghijklmnopqrstuvwxyz."
	static iniFiles := ["AliasList", "TapTap"]
	static builtInFuncs := ["EditAliasListIni", "EditTapTapIni", "EditIniFile"]

	QuitTapTap(_) {
		ExitApp
	}

	ReloadTapTap(_) {
		Reload
	}

	GetIniFileIndex(option, options) {
		if (!option) {
			return 1
		} else {
			for index, value in options {
				if InStr(value, option) {
					return index
				}
			}
			return 0
		}
	}

	EditIniFile(option) {
		if (index :=this.GetIniFileIndex(option, Alias.iniFiles)) {
			fn := Alias.builtInFuncs[index]
			return ObjBindMethod(this, fn).Call("")
		}
		return this.Edit(option)
	}

	EditTapTapIni(_) {
		static isDeferred := false
		if (isDeferred) {
			isDeferred := false
			editor := SetUp.Get("Editor")
			tapTapIniFile := SetUp.iniFile
			RunWait(editor . " " . tapTapIniFile)
			SetUp.isIniChanged := true
			return "DeferredRun, IniChanged"
		} else {
			isDeferred := true
			return "DeferredFunctionEditTapTapIni"
		}
	}

	EditAliasListIni(_) {
		static isDeferred := false
		if (isDeferred) {
			isDeferred := false
			editor := SetUp.Get("Editor")
			aliasListIniFile := SetUp.GetFilePath("AliasList")
			RunWait(editor . " " . AliasListIniFile)
			return "DeferredRun"
		} else {
			isDeferred := true
			return "DeferredFunctionEditAliasListIni"
		}
	}

	Edit(opt) {
		editor := SetUp.Get("Editor")
		Run(editor . " " . opt)
	}

	Run(option) {
		static deferredFunction := ""
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
						python := SetUp.GetFilePath("PythonExe")
						command := python . " " SetUp.GetScriptPath(command)
					}
					Run(command . " " . option . defaultOption, workingDir, &pid)
				case "BuiltIn":
					if (deferredFunction) {
						builtInFunc := ObjBindMethod(this, deferredFunction)
						deferredFunction := ""
						res .= builtInFunc(option)
					} else {
						builtInFunc := ObjBindMethod(this, command)
						if InStr((r := builtInFunc(option)), "DeferredFunction", 1) {
							deferredFunction := StrReplace(r, "DeferredFunction", "", 1)
							return ["DeferredAfterHotkeyReset", 0]
						} else {
							res .= r
						}
					}
				case "Folder":
					Run("Explorer " . command . option . defaultOption, , &pid)
				default:	; Etc
					Run(command . " " . option . " " . defaultOption, workingDir, &pid)
			}
			if (pid)
				WinWaitActive("ahk_pid " . pid)
			return [res . ", Ok", pid]
		} catch Error as e {
			deferredFunction := ""
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

	ParseAlias(token) {
		; 첫 번째 Aliases의 첫 글자가 영문자 소문자가 아니면서, 일치하는 경우: "ShortCut"
		; Return:
		; 첫 별칭에서 처음부터 일치하는 경우: 1
		; 2번째 이후 별칭에서 처음부터 일치하는 경우: 2
		; 중간의 대문자가 일치하는 경우: 3
		; 아무 곳이나 일치하는 경우: 4
		; 일치하는 곳이 없는 경우: 5
		; token 이 "" 인 경우: 6
		if ((tokenLen := StrLen(token)) = 0)
			return 6
		if (tokenLen = 1 and !InStr(Alias.lowerCase, token, true) and SubStr(this.aliases[1], 1, 1) == token) {	; CaseSensitive
			return "ShortCut"
		}

		tokenIndex := 5
		For index, value in this.aliases
		{
			if (left := InStr(value, "[")) {
				right := InStr(value, "]")
				encrypt := SubStr(value, left, right - left + 1)	; [] 내의 내용 보관
				value := Trim(StrReplace(value, encrypt, ""))
			}
			pos := InStr(value, token)
			if (pos = 1) {
				if (index = 1) {
					return 1
				} else {
					return 2
				}
			}
			ch := SubStr(token, tokenLen)
			if (!InStr(Alias.lowerCase, ch, true) and tokenLen > 1) {
				; 중간 대문자 찾기
				p := Instr(value, SubStr(token, 1, tokenLen - 1))
				toSeek := p + tokenLen - 1
				chPos := InStr(SubStr(value, toSeek), ch, true)
				if (p and chPos) {
					tokenIndex := 3
				}
			}
			if (pos and tokenIndex = 5) {
				tokenIndex := 4
			}
		}
		return tokenIndex
	}

	ParseOption(option) {
		if (!this.optArray)
			return [[this.GetAliasesString()], 0]
		list := []
		if (option = " ") {
			for _, value in this.optArray {
				list.Push(value)
			}
			return [list, 1]
		} else if (SubStr(option, 1, 2) = "  ") {
			return [[], 0]
		}
		option := Trim(option)
		optionLen := StrLen(option)
		if (optionLen = 1 and !InStr(Alias.lowerCase, option, true)) {
			for i, value in this.optArray {
				if InStr(value, option, true) {	; CaseSensitive
					return [[value], i]
				}
			}
		}
		ch := SubStr(option, optionLen)
		index := 0
		if (!InStr(Alias.lowerCase, ch, true) and optionLen > 1) {
			for i, value in this.optArray {
				; 중간 대문자 찾기
				p := Instr(value, SubStr(option, 1, optionLen - 1))
				toSeek := p + optionLen - 1
				chPos := InStr(SubStr(value, toSeek), ch, true)
				if (p and chPos) {
					if (!index)
						index := i
					list.Push(value)
				}
			}
			return [list, index]
		}
		for i, value in this.optArray {
			if InStr(value, option) {
				if (!index)
					index := i
				list.Push(value)
			}
		}
		return [list, index]
	}

	GetAliasesString() {
		return this.GetStringFromArray(this.aliases)
	}

	GetArrayFromString(str, isAlias := false) {
		encrypt := ""
		if (isAlias and (left := InStr(str, "["))) {
			try {
				if ((right := InStr(str, "]")) = 0)
					Throw Error("별칭 구문 해석 에러`n']' 기호가 없음.")
				encrypt := SubStr(str, left, right - left + 1)	; [] 내의 내용 보관
				opts := Trim(SubStr(encrypt, 2, StrLen(encrypt) - 2))
				if (opts) {
					this.optArray := []
					Loop Parse, opts, "CSV"
					{
						if Trim(A_LoopField) {
							this.optArray.Push(Trim(A_LoopField))
						}
					}
				}
				str := StrReplace(str, encrypt, "EncryptedOption")
			} catch Error as e {
				MsgBox(e.Message, "Alias Parsing Error", 16)
				ExitApp
			}
		}
		array_ := []
		Loop Parse, str, "CSV"
		{
			if InStr(A_LoopField, "EncryptedOption", true) {
				array_.push(Trim(StrReplace(A_LoopField, "EncryptedOption", encrypt, 1)))
			} else {
				array_.push(Trim(A_LoopField))
			}
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
		this.optArray := ""
		this.aliasType := aliasType
		this.aliases := this.GetArrayFromString(aliasesLine, true)

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
