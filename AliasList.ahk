#Include "Alias.ahk"
Class AliasList {
	static aliasTypes := ["Run", "Script", "BuiltIn", "Site", "Folder", "NewRun", "Etc"]
	static aliasList := ""	; Alias List 배열
	static modificationTime := ""
	static previousAlias := ""
	static aliasIndex := 0	; 선택하는 Alias의 AliasList 배열에서의 index
	static aliasId := 0
	static aliasListFile := A_WorkingDir . "\Lib\_SetUp\AliasList.ini"
	static onBootAlias := ""

	static __New() {
		AliasList.MakeList()
	}

	static ListAlias(alias) {
		AliasList.MakeList()

		command := Trim(alias)
		; alias 일치 list 생성
		List1 := []
		List2 := []
		List3 := []
		List4 := []
		For index, value in AliasList.aliasList
		{
			res := value.CheckAlias(command)
			if (res = "ImmediateRun") {
				AliasList.aliasIndex := index
				return ["ImmediateRun"]
			}
			if (res = 1) {
				List1.Push(index)
			} else if (res = 2) {
				List2.Push(index)
			} else if (res = 3) {
				List3.Push(index)
			} else if (res = 4) {
				List4.Push(index)
			}
		}
		; 순서 지정 list
		list := []
		AliasList.aliasIndex := 0
		For index, value in List1
		{
			if (AliasList.aliasIndex = 0)
				AliasList.aliasIndex := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List2
		{
			if (AliasList.aliasIndex = 0)
				AliasList.aliasIndex := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List3
		{
			if (AliasList.aliasIndex = 0)
				AliasList.aliasIndex := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List4
		{
			if (AliasList.aliasIndex = 0)
				AliasList.aliasIndex := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		return list
	}

	static RunOnBoot() {
		AliasList.onBootAlias.Run("")
	}

	static RunAlias(alias) {
		command := Trim(alias)
		option := ""
		; 명령어와 옵션 분리
		space := InStr(alias, " ")
		if (space != 0) {
			command := Trim(SubStr(command, 1, space - 1))
			option := Trim(SubStr(alias, space + 1))
		}

		aliasIndex := AliasList.aliasIndex
		if (AliasList.aliasIndex != 0) {
			res := AliasList.aliasList[AliasList.aliasIndex].Run(option)
			if InStr(res[1], "Ok") {
				AliasList.previousAlias := command
			} else {
				AliasList.previousAlias	:= ""
			}
		} else {
			AliasList.previousAlias	:= ""
		}
		return res
	}

	static MakeList() {
		; ini 파일 생성
		aliasListFile := AliasList.aliasListFile
		if !FileExist(aliasListFile) {
			FileInstall("AliasList.ini.Default", aliasListFile, 0)
		}
		; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		fileTime := FileGetTime(aliasListFile, "M")
		if (AliasList.modificationTime = fileTime) {
			return
		} else {
			AliasList.modificationTime := fileTime
		}
		;ini 파일의 Section을 이용하여 AliasList 작성
		aliasList_ := []
		aliasLine := ""
		aliasType := ""
		commandLine := ""
		sectionList := IniRead(aliasListFile)
		Loop parse sectionList, "`n" {
			if (A_LoopField != "OnBoot") {
				aliasLine := IniRead(aliasListFile, A_LoopField, "Alias")
			}
			command := AliasList.GetCommandLine(aliasListFile, A_LoopField)
			aliasType := command[1]
			commandLine := command[2]
			alias_ := Alias(aliasType, aliasLine, commandLine)
			if (A_LoopField != "OnBoot") {
				aliasList_.push(alias_)
			} else {
				AliasList.onBootAlias := alias_
			}
		}
		AliasList.aliasList := aliasList_
	}

	static WriteList() {
		iniFile := "Test.ini"
		for index, alias_ in AliasList.aliasList {
			section := "별칭 " . index
			IniWrite(alias_.GetAliasesString(), iniFile, section, "Alias")
			aliasType := alias_.aliasType
			IniWrite(alias_.GetCommandString(), iniFile, section, aliasType)
		}
	}

	static GetCommandLine(aliasListFile, section) {
		commandLine := ""
		aliasType := ""
		for index, aType in AliasList.aliasTypes {
			commandLine := IniRead(aliasListFile, section, aType, "")
			if (commandLine) {
				aliasType := AliasList.aliasTypes[index]
				break
			}
		}
		return [aliasType, commandLine]
	}
}
