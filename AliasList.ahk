#Include, %A_WorkingDir%\Alias.ahk

Class AliasList {
	static aliasList := ""	; Alias List 배열
	static creationTime := ""
	static previousAlias := ""
	static previousOption := ""
	static aliasIndex := 0	; 선택하는 Alias의 AliasList 배열에서의 index
	static aliasId := 0
	static aliasIniFile := "Lib\AliasList.ini"

	__New() {
		if !FileExist(AliasList.aliasIniFile) {
			this.MakeProtoIniFile()
		}
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
			if (res = "Hotkey") {
				AliasList.aliasIndex := index
				return ["RunHotkey"]
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
			if (res = "Ok") {
				AliasList.previousAlias := command
				AliasList.previousOption := option
			} else {
				AliasList.previousAlias	:= ""
				AliasList.previousOption := ""
			}
		} else {
			AliasList.previousAlias	:= ""
			AliasList.previousOption := ""
		}
	}

	MakeList() {
		if !FileExist(AliasList.aliasIniFile) {	; 초기 ini 파일 생성
			this.MakeProtoIniFile()
		}
		; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		aliasConfig := AliasList.aliasIniFile
		FileGetTime, fileTime , % aliasConfig
		if (AliasList.creationTime = fileTime) {
			return
		} else {
			AliasList.creationTime := fileTime
		}
		; ini 파일의 Section을 이용하여 AliasList 작성
		try {
			aliasList_ := []
			Loop, read, %aliasConfig%
			{
				if InStr(A_LoopReadLine, "#")
					continue
				left := InStr(A_LoopReadLine, "[")
				right := InStr(A_LoopReadLine, "]")
				if (left != 0 and right != 0 and right - left > 1) {
					section := SubStr(A_LoopReadLine, left + 1, right - left - 1)
					alias_ := this.MakeAliasFromIni(section)
					aliasList_.push(alias_)
				}
			}
			AliasList.aliasList := aliasList_
		} catch e {
			MsgBox, %e%
			ExitApp
		}
	}

	MakeAliasFromIni(section) {
		configFile := AliasList.aliasIniFile
		; IniRead, comment, %configFile%, %section%, 주석(Comment), ""
		key := "별칭(Aliases, ...)"
		IniRead, aliases, %configFile%, %section%, %key%, ""
		IniRead, aliasType, %configFile%, %section%, 명령어 타입(Command Type), ""
		IniRead, command, %configFile%, %section%, 명령어(Command), ""
		IniRead, option, %configFile%, %section%, 명령어 옵션(Option), ""
		IniRead, workingDir, %configFile%, %section%, 작업 디렉토리(Working Folder), ""
		IniRead, showCmd, %configFile%, %section%, 실행 창 상태(Show Command), ""
		IniRead, winTitle, %configFile%, %section%, 윈도우 창 제목(Winow Title), ""
		IniRead, mainMenu, %configFile%, %section%, 메인 메뉴 이름(Mainmenu), ""
		IniRead, mainIndex, %configFile%, %section%, 메인 메뉴 순번(Mainmenu Index), ""
		key := "하위 메뉴 이름(Submenu, ...)"
		IniRead, subMenu, %configFile%, %section%, %key%, ""
		key := "하위 메뉴 순번(Submenu Index, ...)"
		IniRead, subIndex, %configFile%, %section%, %key%, ""
		return new Alias("", aliases, aliasType, command, option, workingDir, showCmd, winTitle, mainMenu, mainIndex, subMenu, subIndex)
	}

	WriteAliasToIni(alias_, num) {
		configFile := AliasList.aliasIniFile
		section := "명령어_별칭_"
		value := alias_.comment
		IniWrite, %value%, %configFile%, %section%%num%, 주석(Comment)
		value := alias_.GetAliasesString(alias_.aliases)
		IniWrite, %value%, %configFile%, %section%%num%, 별칭(Aliases, ...)
		value := alias_.aliasType
		IniWrite, %value%, %configFile%, %section%%num%, 명령어 타입(Command Type)
		value := alias_.command
		IniWrite, %value%, %configFile%, %section%%num%, 명령어(Command)
		value := alias_.option
		IniWrite, %value%, %configFile%, %section%%num%, 명령어 옵션(Option)
		value := alias_.workingDir
		IniWrite, %value%, %configFile%, %section%%num%, 작업 디렉토리(Working Folder)
		value := alias_.showCmd
		IniWrite, %value%, %configFile%, %section%%num%, 실행 창 상태(Show Command)
		value := alias_.winTitle
		IniWrite, %value%, %configFile%, %section%%num%, 윈도우 창 제목(Winow Title)
		value := alias_.mainMenu
		IniWrite, %value%, %configFile%, %section%%num%, 메인 메뉴 이름(Mainmenu)
		value := alias_.mainIndex
		IniWrite, %value%, %configFile%, %section%%num%, 메인 메뉴 순번(Mainmenu Index)
		value := alias_.GetSubMenuString(alias_.subMenu)
		IniWrite, %value%, %configFile%, %section%%num%, 하위 메뉴 이름(Submenu, ...)
		value := alias_.GetSubIndexString(alias_.subIndex)
		IniWrite, %value%, %configFile%, %section%%num%, 하위 메뉴 순번(Submenu Index, ...)
	}

	MakeProtoIniFile() {
		configFile := AliasList.aliasIniFile
		FileAppend,
(
# 별칭 명령어 리스트 파일
# 파일 명: AliasList.ini
#
# "#" 기호가 있는 라인의 글은 전부 제거되므로, "#"을 주석 용도로 사용하지 말 것.
#
# Alias: 프로그램의 별칭, 별명을 뜻하며, 별명의 일부만을 입력하여 프로그램을 실행하는 용도임.
#
# 별칭 명령어 리스트 파일 제작 도움말:
# 아래 항목 중 "별칭(Aliases, ...)=" 우측의 ","로 구분된 별칭들이 하나의 별칭 명령이 됨.
#
# [명령어_별칭_숫자xxx](Section): 각각의 별칭 명령어 구분을 위한 섹션 명칭을 대괄호 사이에 넣음.
#    모든 섹션 명칭은 임의의 이름을 사용할 수 있으나,
#    섹션 상호 간의 구별을 위하여 대괄호[] 안에 서로 다른 이름을 넣어야 함.
#    컴퓨터는 섹션 명칭을 별칭을 구분하기 위한 용도로 사용할 뿐 내용은 무시함.
# 주석(Comment): 사람이 참조할 주석 용도로 사용. 컴퓨터는 내용을 무시함.
# 별칭(Aliases, ...): 사용할 프로그램의 별명(별칭)으로 한글을 포함한 모든 문자 형식 사용 가능
#    여러 개의 별명을 사용할 경우, 앞 쪽의 별명부터 먼저 선택하여 호출 됨.
#    별명은 대소문자 구분이 없으므로, 표기할 때는 대소문자를 혼용하되, 소문자로 실행할 것.
#    예외: ?, 숫자(0 ~ 9), 영어 대문자 1 문자(A ~ Z)는 즉각 실행 명령으로 사용됨.
# 명령어(Command): 별칭을 사용해서 실행할 프로그램의 위치.
#    윈도우에선 "\"을 사용해도 좋고, "/"를 대신 사용해도 좋다.
# 명령어 타입(Command Type): 사용할 별명의 프로그램 유형으로 아래와 같은 형식이 있으며 정확한 이름을 사용해야 함.
#    Run: 확장자가 *.exe, *.cmd, *.bat, *.vbs 등인 프로그램을 실행하는 Alias 타입.
#        command에 지정해 놓은 위치의 파일을 실행하며, win_title에 "윈도우 타이틀"이 존재할 경우,
#        해당 "윈도우 타이틀"을 이용하여 실행 중인 프로그램을 찾아보고,
#        해당 프로그램이 이미 실행 중이면 그 프로그램을 활성화 시킴.
#        실행 중인 프로그램을 찾을 수 없으면, 당연히 해당 프로그램을 실행 시킴.
#        win_title에 내용이 없으면, NewRun처럼 그냥 command에 지정된 위치의 파일을 실행 시킴.
#    NewRun: win_title에 "윈도우 타이틀" 존재 여부와 관계없이,
#        무조건 해당 프로그램을 새로 실행 시킴.
#        따라서, 기존에 해당 프로그램이 실행 중일 지라도, 새로운 프로그램이 또 실행됨.
#    Script: python이나 auto hotkey 프로그램의 스크립트를 실행 시킴.
#    Folder: "파일 탐색기"로 폴더 열기 명령.
#        별칭 cmd가 더 유용함
#    Site: 인터넷 익스플로러로 "Web Site"나 "Home Page" 열기 명령.
#        별칭 www가 더 유용함.
#    Etc: alias_type이 없는 경우를 위한 타입으로, 해당 Alias는 무시되며 저장되지 않음.
#        예를 들면, "계산기"의 경우, 도스 "cmd 창"에서 "calc"라고 타이핑만 하면 바로 실행할 수 있음.
#        이런 경우, "별칭 명령어 상자"에서 별도의 "별명 제작" 없이도 사용 가능함.
#        이런 명령을 "별칭 명령어 상자"에서 사용할 경우, Etc 타입이 됨.
#        참고로, 아래의 "calculator" 별칭은 "Run" 타입이므로 경우에 따라,
#        "c" 라는 문자 단 1 문자 만으로도 실행이 가능하다는 점에서 "Etc" 타입과 차이가 있음.
#    Hotkey: 특수한 키들의 조합으로 프로그램을 실행하는 유형.
#        Shift 키, Control 키, Alt 키, Function 키, Window 키 등의 조합이 가능함.
# 명령어 옵션(Option): 명령어에 지정한 프로그램을 실행할 때 제공할 옵션.
#        "별칭 명령어 상자(ARB)"에서 옵션을 제공할 경우에는, command에 제공된 옵션은 무시됨.
# 작업 디렉토리(Working Folder): 지정할 경우, 해당 디렉토리로 이동한 후, 명령어가 가르키는 프로그램 실행.
# 실행 창 상태(Show Command): 프로그램 실행 시, 윈도우의 표시 상태를 지정하며 아래 옵션 참조.
#    restore: 일반적인 실행 화면으로, 실행 창 상태 항목이 비어 있으면 적용됨.
#    min: 윈도우 화면이 최소화된 상태로 실행.
#    max: 윈도우 화면이 최대화된 상태로 실행.
# 윈도우 창 제목(Winow Title): 실행할 프로그램의 "윈도우 타이틀"로 명령어 타입이 run타입일 경우,
#    윈도우 창 제목에 제공된 윈도우 타이틀을 참고하여, 해당 프로그램이 이미 실행 중이면,
#    새로운 프로그램을 실행하지 않고, 기존에 실행 중인 프로그램을 활성화 상태로 만듬.
# 메인 메뉴 이름(Mainmenu: 메뉴를 사용할 경우, 해당 별칭이 소속될 메인 메뉴 이름.
# 메인 메뉴 순번(Mainmenu Index): 메인 메뉴의 표시 순서를 나타내는 표식으로 컴퓨터가 번호를 부여하므로 건드리지 말 것.
#    메인 메뉴의 표시 순서를 바꾸고자 할 경우, 메뉴 사용 중에 순서 변경이 가능함.
# 하위 메뉴 이름(Submenu, ...): 메인 메뉴 밑에 있는 하위 메뉴에 소속될 경우, 메인 메뉴와 하위 메뉴를 같이 만들어야 함.
#    하위 메뉴는 계층적으로 무한히 가지를 칠 수 있으므로,
#    원하는 만큼 계층 구조를 문자열로 구분하여 표현할 수 있음.
# 하위 메뉴 순번(Submenu Index, ...): 메인 메뉴 밑의 하위 메뉴의 표시 순서를 나타내는 표식으로 컴퓨터가 번호를 부여하므로 건드리지 말 것.
#    하위 메뉴의 표시 순서를 바꾸고자 할 경우, 메뉴 사용 중에 순서 변경이 가능함.
#
), % configFile, UTF-16

		num := 1
		alias_ := new Alias("주석 란: 어떤 내용을 적어도 무시되는 칸", "?, 도움말", "Hotkey", "")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("숫자 Hotkey 테스트: 숫자 1을 누르면 탭탭이가 인사함.", "1, 인사하기", "Hotkey", "")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("파일 탐색기를 이용하여 현재 폴더 화면을 보여줌.", "., 현재 폴더 열기", "Folder", ".")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("파일 탐색기를 이용하여 상위 부모 폴더 화면을 보여줌.", ".., 부모 폴더 열기", "Folder", "..")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("가끔 사용하지만, 필요할 때마다 매 번 찾기 귀찮아서 별명으로 제작.", "calculator, 계산기", "Run", "calc")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "cmd, 커맨드 창", "Run", "cmd")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "cmd [], 옵션을 받는 커맨드 창", "Script", "Command")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "menu [], 런처(Launcher) 메뉴", "Script", "Menu")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "Q, 탭탭이 종료", "Hotkey", "")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "R, 탭탭이 재 실행", "Hotkey", "")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("", "www [], 크롬", "Script", "Chrome")
		this.WriteAliasToIni(alias_, num++)
		alias_ := new Alias("Etc 타입은 이하에 어떤 내용을 적어도 전혀 저장되지 않음.", "zzzZz, 별칭이 없는 프로그램 작성 용도로 불러 쓸 수가 없음.", "Etc", "")
		this.WriteAliasToIni(alias_, num++)
	}
}
