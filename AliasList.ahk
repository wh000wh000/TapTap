#Include "Alias.ahk"
Class AliasList {
	static aliasList := ""	; Alias List 배열
	static modificationTime := ""
	static previousAlias := ""
	static aliasIndex := 0	; 선택하는 Alias의 AliasList 배열에서의 index
	static aliasId := 0
	static aliasListFile := A_WorkingDir . "\Lib\_SetUp\AliasList.ini"
	static onBootAlias := ""

	__New() {
		this.MakeList()
	}

	ListAlias(alias) {
		this.MakeList()

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

	RunOnBoot() {
		AliasList.onBootAlias.Run("")
	}

	RunAlias(alias) {
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
			if InStr(res, "Ok") {
				AliasList.previousAlias := command
			} else {
				AliasList.previousAlias	:= ""
			}
		} else {
			AliasList.previousAlias	:= ""
		}
		return res
	}

	MakeList() {
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
		; ini 파일의 Section을 이용하여 AliasList 작성
		try {
			aliasList_ := []
			aliasLine := ""
			aliasType := ""
			typeLine := ""
			isAliasParsing := false
			parsingStage := 0
			Loop read, aliasListFile
			{
				if (Trim(A_LoopReadLine) = "" or InStr(A_LoopReadLine, "#"))	; '#'을 포함한 줄은 모두 제거
					continue
				if (!isAliasParsing and InStr(A_LoopReadLine, "<Alias>")) {
					pos := InStr(A_LoopReadLine, ">")
					aliasLine := Trim(SubStr(A_LoopReadLine, pos + 1))
					parsingStage := 1
				} else if (!isAliasParsing and InStr(A_LoopReadLine, "<OnBoot>")) {
					parsingStage := 2
				} else if ((!isAliasParsing and RegExMatch(A_LoopReadLine, "i)<[a-z]+>"))
					and !InStr(A_LoopReadLine, "<Alias>") and !InStr(A_LoopReadLine, "<OnBoot>")) {
					left := InStr(A_LoopReadLine, "<")
					right := InStr(A_LoopReadLine, ">")
					aliasType := Trim(SubStr(A_LoopReadLine, left + 1, right - left - 1))
					typeLine := Trim(SubStr(A_LoopReadLine, right + 1))
					isAliasParsing := true
				} else {
					Throw "별칭 명령어 구문 해석 실패"
				}
				if (!isAliasParsing)
					continue

				alias_ := Alias(aliasType, aliasLine, typeLine)
				if (parsingStage = 1) {
					aliasList_.push(alias_)
				} else if (parsingStage = 2) {
					AliasList.onBootAlias := alias_
				}
				isAliasParsing := false
				parsingStage := 0
			}
			AliasList.aliasList := aliasList_
		} catch Error as e {
			MsgBox(e, "명령어 리스트 에러", 16)
			ExitApp
		}
	}
}
