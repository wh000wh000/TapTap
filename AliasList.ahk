#Include "SetUp.ahk"
#Include "Alias.ahk"
Class AliasList {
	static aliasTypes := ["Run", "Script", "BuiltIn", "Site", "Folder", "NewRun", "Etc"]
	static aliasList := ""	; Alias List 배열
	static modificationTime := ""
	static previousAlias := ""
	static aliasId := 0	; 선택하는 Alias의 AliasList 배열에서의 index
	static optionId := 0
	static isShortCut := false
	static aliasListFile := ""
	static onBootAlias := ""

	static __New() {
		AliasList.MakeList()
	}

	static ListAlias(alias_) {
		AliasList.MakeList()
		; command, option 분리
		option := ""
		if (pos := InStr(alias_, " ")) {
			command := Trim(SubStr(alias_, 1, pos - 1))
			if (!command) {
				AliasList.aliasId := 0
				return []
			}
			option := SubStr(alias_, pos)
		} else {
			command := alias_
		}
		; option 처리 먼저
		if (option and AliasList.aliasId) {
			list := AliasList.aliasList[AliasList.aliasId].ParseOption(option)
			AliasList.optionId := list[2]
			return list[1]
		} else {
			AliasList.optionId := 0
		}
		; alias_ 일치 list 생성
		List1 := []
		List2 := []
		List3 := []
		List4 := []
		For index, value in AliasList.aliasList
		{
			; res := value.CheckAlias(command)
			res := value.ParseAlias(command)
			if (res = "ShortCut") {
				AliasList.aliasId := index
				AliasList.isShortCut := true
				return ["ShortCut"]
			}
			if (res = 6 or res = 1) {
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
		AliasList.aliasId := 0
		For index, value in List1
		{
			if (AliasList.aliasId = 0)
				AliasList.aliasId := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List2
		{
			if (AliasList.aliasId = 0)
				AliasList.aliasId := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List3
		{
			if (AliasList.aliasId = 0)
				AliasList.aliasId := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in List4
		{
			if (AliasList.aliasId = 0)
				AliasList.aliasId := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		AliasList.isShortCut := res = 6 ? true: false	; 다짜고짜 Tab, Enter 누를 때
		return list
	}

	static RunOnBoot() {
		if (AliasList.onBootAlias)
			AliasList.onBootAlias.Run("")
	}

	static RunAlias(alias) {
		if (alias and (command := Trim(alias)) = "") {	; Tab 처리
			return ["Error", ""]
		}
		option := ""
		; 명령어와 옵션 분리
		space := InStr(alias, " ")
		if (space != 0) {
			command := Trim(SubStr(command, 1, space - 1))
			option := Trim(SubStr(alias, space + 1))
		}

		aliasId := AliasList.aliasId
		if (AliasList.aliasId != 0) {
			if (optionId := AliasList.optionId) {
				option := AliasList.aliasList[AliasList.aliasId].optArray[optionId]
			}
			res := AliasList.aliasList[AliasList.aliasId].Run(option)
			if (AliasList.isShortCut) {
				AliasList.previousAlias	:= ""
				AliasList.isShortCut := false
			} else if !InStr(res[1], "Error") {
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
		aliasListFile := AliasList.aliasListFile := SetUp.GetFilePath("AliasList")
		if (!FileExist(aliasListFile)) {
            pos := InStr(aliasListFile, "\", , -1)
            if (pos)
                DirCreate(SubStr(aliasListFile, 1, pos - 1))
			FileInstall("Src\AliasList.ini", aliasListFile, 0)
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
		schedule := ""
		aliasType := ""
		commandLine := ""
		sectionList := IniRead(aliasListFile)
		Loop parse sectionList, "`n" {
			try {
				schedule := ""
				if !(aliasLine := IniRead(aliasListFile, A_LoopField, "Alias", "")) {
					if !(schedule := IniRead(aliasListFile, A_LoopField, "Schedule", "")) {
						Throw Error(A_LoopField . "의 Alias가 없습니다.")
					}
				}
				command := AliasList.GetCommandLine(aliasListFile, A_LoopField)
				aliasType := command[1]
				commandLine := command[2]
				if (!aliasType or !commandLine) {
					Throw Error(A_LoopField . "의 명령어 타입을 알 수 없습니다.")
				}
				alias_ := Alias(aliasType, aliasLine, commandLine)
				if (A_LoopField != "OnBoot") {
					if (!schedule) {
						aliasList_.push(alias_)
					} else {
						Throw Error("Schedule 처리")
					}
				} else {
					AliasList.onBootAlias := alias_
				}
			} catch Error as e {
				MsgBox("별칭 구문 분석 에러`n" . e.Message, "별칭 리스트 작성", 16)
			}
		}
		AliasList.aliasList := aliasList_
		; AliasList.WriteAliasList()
	}

	static WriteAliasList() {
		iniFile := "Test.ini"
		section := "OnBoot"
		IniWrite(AliasList.onBootAlias.GetAliasesString(), iniFile, section, "Alias")
		aliasType := AliasList.onBootAlias.aliasType
		IniWrite(AliasList.onBootAlias.GetCommandString(), iniFile, section, aliasType)
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
