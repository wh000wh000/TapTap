class SetUp {
    static dict := {
        tapTapIniFile : A_WorkingDir . "\Lib\_SetUp\TapTap.ini",
        tapTapIniModifiedTime : "",
        aliasListIniModifiedTime : ""
    }

    static __new() {
        SetUp.MakeDict()
    }

    static Get(key) {
        SetUp.MakeDict()

        try {
            res := SetUp.dict.%key%
        } catch {
            res := ""
        }

        return res
    }

    static MakeDict() {
        ; ini 파일 생성
        setUpFile := SetUp.dict.tapTapIniFile
        if !FileExist(setUpFile) {
            FileInstall("TapTap.ini.Default", setUpFile, 0)
		}
        ; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		fileTime := FileGetTime(setUpFile, "M")
		if (!SetUp.dict.tapTapIniModifiedTime and SetUp.dict.tapTapIniModifiedTime = fileTime) {
			return
		}
        SetUp.dict.tapTapIniModifiedTime := fileTime
    	; 환경 설정 파일 읽기
        section := "탭탭이 환경 설정"
        newDict := SetUp.dict.Clone()
        newDict.hotkey := IniRead(setUpFile, section, "Hotkey", "Control")
        newDict.tapTap := IniRead(setUpFile, section, "TapTap", "false") = "false" ? false: true
        newDict.tapTapSpeed := IniRead(setUpFile, section, "TapTapSpeed", 350)
        newDict.autoHotkey := IniRead(setUpFile, section, "AutoHotkey", "Lib\_SetUp\AutoHotkey.exe")
        newDict.tapTapIniFile := IniRead(setUpFile, section, "TapTapIniFile", "Lib\_SetUp\TapTap.ini")
        newDict.aliasListIniFile := IniRead(setUpFile, section, "AliasListIniFile", "Lib\_SetUp\AliasList.ini")
        newDict.arbWidth := IniRead(setUpFile, section, "ArbWidth")
        newDict.editor := IniRead(setupFile, section, "Editor")
        SetUp.dict := newDict
    }
}
