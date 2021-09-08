Class Alias {
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
}
