Class Alias {
	static lowerCase := "abcdefghijklmnopqrstuvwxyz."

	Run(option) {
		alias_ := this.aliases[1]
		if (StrLen(alias_) = 1 and InStr(Alias.lowerCase, alias_, true) = 0)	; CaseSensitive
			return "ImmediateRun"
		return "Ok"
	}

	CheckAlias(alias_) {
		; 즉각 실행 명령
		if (StrLen(alias_) = 1 and this.aliases[1] = alias_ and !InStr(Alias.lowerCase, alias_, true))
			return "ImmediateRun"

		this.aliasIndex := 0
		For index, value in this.Aliases
		{
			pos := InStr(value, alias_)	; alias가 "" 이면, 항상 1 반환
			if (pos != 0 and (this.aliasIndex = 0 || pos < this.aliasIndex))
				this.aliasIndex := pos
			if (pos = 1)
				break
		}
		return this.aliasIndex
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
			if (elem != "")
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

	__New(comment:="", aliases:="", command:="", aliasType:="", option:= "", workingDir:="", showCmd:="", winTitle:="", mainMenu:= "", mainIndex:="", subMenu:="", subIndex:="") {
		this.comment := comment
		this.aliases := this.GetArrayFromString(aliases)
		this.command := command
		this.aliasType := aliasType
		this.option := option
		this.workingDir := workingDir
		this.showCmd := showCmd
		this.winTitle := winTitle
		this.mainMenu := mainMenu
		this.mainIndex := mainIndex
		this.subMenu := this.GetArrayFromString(subMenu)
		this.subIndex := this.GetArrayFromString(subIndex)
		this.aliasIndex := 0
	}
}
