class Alias {
	static lowerCase := "abcdefghijklmnopqrstuvwxyz."

	; 탭탭이 종료
	; BuiltIn 'Q'키
	BuiltInQuit() {
		hotkey := T_SetUp.dict["Hotkey"]
		Hotkey, %hotkey%, ShowAliasRunBox, Off
		T_SetUp.WriteSetUpFile()
		ExitApp
	}

	; 탭탭이 재 실행
	; 'R'키 Hotkey
	BuiltInReload() {
		hotkey := T_SetUp.dict["Hotkey"]
		Hotkey, %hotkey%, ShowAliasRunBox, Off
		T_SetUp.WriteSetUpFile()
		Reload
	}

	Run(option) {
		alias_ := this.aliases[1]
		aliasType := this.aliasType
		command := this.command
		defaultOption := this.option
		workingDir := this.workingDir
		try {
			if (aliasType = "BuiltIn") {
				func := "BuiltIn" . command
				builtInFunc := ObjBindMethod(this, func)
				%builtInFunc%()
				return "BuiltIn"
			} else if (aliasType = "Hotkey") {
				Run, %command% %defaultOption%, %workingDir%
				return "Hotkey"
			} else if (aliasType = "Etc") {
				Run, %command% %option% %defaultOption%, %workingDir%
			} else {
				Run, %command% %option% %defaultOption%, %workingDir%
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
			return "Ok"
		} catch e {
			msg := "명령어 타입: " . aliasType . "`n"
			msg .= "명령어: " . command . "`n"
			msg .= "옵션: " . option . defaultOption . "`n"
			msg .= "작업 폴더: " . workingDir . "`n"
			msg .= e
			MsgBox, 16, "별칭 명령 실행 에러", %msg%
			return "Error"
		}
	}

	CheckAlias(alias_) {
		; 즉각 실행 명령
		if ((this.aliasType = "Hotkey" or this.aliasType = "BuiltIn") and alias_ != "") {
			if (StrLen(alias_) = 1 and !InStr(Alias.lowerCase, alias_, true) and SubStr(this.aliases[1], 1, 1) == alias_)	; CaseSensitive
				return "ImmediateRun"
		}

		aliasIndex := 0
		For index, value in this.Aliases
		{
			pos := InStr(value, alias_)	; alias가 "" 이면, 항상 1 반환
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
		if (typeArray.Length()) {
			this.command := Trim(typeArray.RemoveAt(1))
		}
		if (typeArray.Length()) {
			this.option := Trim(typeArray.RemoveAt(1))
		}
		if (typeArray.Length()) {
			this.workingDir := Trim(typeArray.RemoveAt(1))
		}
		if (typeArray.Length()) {
			this.winTitle := Trim(typeArray.RemoveAt(1))
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
	i_New(comment:="", aliases:="", aliasType:="", command ="", option:= "", workingDir:="", showCmd:="", winTitle:="", mainMenu:= "", mainIndex:="", subMenu:="", subIndex:="") {
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
