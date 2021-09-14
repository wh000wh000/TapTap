#Include, Alias.ahk
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
		firstList := []
		anyList := []
		For index, value in AliasList.aliasList
		{
			res := value.CheckAlias(command)
			if (res = "ImmediateRun") {
				AliasList.aliasIndex := index
				return ["ImmediateRun"]
			}

			if (res != 0) {
				if (res = 1) {
					firstList.Push(index)
				} else {
					anyList.Push(index)
				}
			}
		}
		; 순서 지정 list
		list := []
		AliasList.aliasIndex := 0
		For index, value in firstList
		{
			if (AliasList.aliasIndex = 0)
				AliasList.aliasIndex := value
			list.Push(AliasList.aliasList[value].GetAliasesString())
		}
		For index, value in anyList
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
			FileInstall, AliasList.ini.Default, %aliasListFile%, 0
		}
		; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		FileGetTime, fileTime , % aliasListFile, M
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
			isAliasParsing := true
			Loop, read, %aliasListFile%
			{
				if (Trim(A_LoopReadLine) = "" or InStr(A_LoopReadLine, "#"))	; '#'을 포함한 줄은 모두 제거
					continue
				if (isAliasParsing and InStr(A_LoopReadLine, "<Alias>")) {
					pos := InStr(A_LoopReadLine, ">")
					aliasLine := Trim(SubStr(A_LoopReadLine, pos + 1))
				} else if (!isAliasParsing and RegExMatch(A_LoopReadLine, "i)<[a-z]+>") and !InStr(A_LoopReadLine, "<Alias>")) {
					left := InStr(A_LoopReadLine, "<")
					right := InStr(A_LoopReadLine, ">")
					aliasType := Trim(SubStr(A_LoopReadLine, left + 1, right - left - 1))
					typeLine := Trim(SubStr(A_LoopReadLine, right + 1))
				} else {
					Throw, "별칭 명령어 구문 해석 실패"
				}
				if (isAliasParsing) {
					isAliasParsing := false
					continue
				} else {
					isAliasParsing := true
				}
				alias_ := new Alias(aliasType, aliasLine, typeLine)
				if (alias_.aliasType = "OnBoot") {
					AliasList.onBootAlias := alias_
				} else {
					aliasList_.push(alias_)
				}
				isAliasParsing := true
			}
			AliasList.aliasList := aliasList_
		} catch e {
			MsgBox, 16, 별칭 명령어 리스트, %e%
			ExitApp
		}
	}
}
