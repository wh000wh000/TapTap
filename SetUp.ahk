class SetUp {
    static setUpFile := A_WorkingDir . "\Lib\_SetUp\TapTap.ini"
    static modificationTime := ""
    static dict := ""
    static newDict := ""
    __new() {
        this.MakeDict()
    }

    GetValue(key) {
        this.ListDict()
        return SetUp.dict[key]
    }

    ListDict() {
        ; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		setUpFile := SetUp.setUpFile
		fileTime := FileGetTime(setUpFile, "M")
		if (SetUp.modificationTime = fileTime) {
			return
		}
    	this.MakeDict()
    }

    MakeDict() {
        setUpFile := SetUp.setUpFile
        if !FileExist(setUpFile) {
            FileInstall("TapTap.ini.Default", setUpFile, 0)
		}

        SetUp.newDict := map()
        try {
            Loop read, setUpFile
            {
               if (Trim(A_LoopReadLine) = "" or InStr(A_LoopReadLine, "#"))	; '#'을 포함한 줄은 모두 제거
                   continue
               if ((pos := InStr(A_LoopReadLine, "=")) = 0) {
                   Throw "환경 설정 구문 해석 에러"
               }
               key := Trim(SubStr(A_LoopReadLine, 1, pos - 1))
               value := Trim(SubStr(A_LoopReadLine, pos + 1))
               SetUp.newDict[key] := value
            }
            fileTime := FileGetTime(setUpFile, "M")
            SetUp.modificationTime := fileTime
        } catch Error as e {
			MsgBox(e.Message, , 16)
            if (SetUp.dict = "")
                ExitApp
            else {
                SetUp.newDict := ""
                return
            }
		}
    }
}
