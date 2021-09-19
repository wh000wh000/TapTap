class SetUp {
    static iniFile := ""
    static isIniChanged := false
    static dict := {
        IniModifiedTime : ""
    }

    static __new() {
        SetUp.MakeDict()
    }

    ; 탭탭이 전용 파일(*.ini, AutoHotkey.exe) 찾기
    static GetFilePath(fileName) {
        dirPath := "WorkingFolder"
        filePath := SetUp.dict.%fileName%
        if InStr(filePath, dirPath)
            filePath := StrReplace(filePath, dirPath, A_WorkingDir)
        return filePath
    }

    ; 탭탭이 Script 전용 폴더에서 Script 파일 패스 찾기
    static GetScriptPath(script) {
        if (!InStr(script, ":") and pos:= InStr(script, ".", , -1)) {
            fType := SubStr(script, pos + 1)
            if (fType = "ahk") {
                folder := SetUp.dict.AhkFolder
            } else if (fType = "py") {
                folder := SetUp.dict.PythonFolder
            }
            if (folder) {
                dirPath := "WorkingFolder"
                if InStr(folder, dirPath)
                    folder := StrReplace(folder, dirPath, A_WorkingDir)
                return folder . "\" . script
            }
        }
        return script
    }

    static Get(key) {
        if (SetUp.isIniChanged) {
            SetUp.MakeDict()
        }

        try {
            res := SetUp.dict.%key%
        } catch {
            res := ""
        }

        return res
    }

    static MakeDict() {
        ; ini 파일 생성
        setUpFile := SetUp.IniFile := A_WorkingDir . "\Lib\TapTap.ini"
        SetUp.dict.WorkingFolder := A_WorkingDir
        if !FileExist(setUpFile) {
            SetUp.CreateFolder(A_WorkingDir . "\Lib")
            FileInstall("Src\TapTap.ini", setUpFile, 0)
		}
        ; ini 날짜 비교, ini 파일 수정 시만 새로 List 작업
		fileTime := FileGetTime(setUpFile, "M")
		if (!SetUp.dict.IniModifiedTime and SetUp.dict.IniModifiedTime = fileTime) {
			return
		}
        SetUp.dict.IniModifiedTime := fileTime
    	; 환경 설정 파일 읽기
        section := "탭탭이 환경 설정"
        newDict := SetUp.dict.Clone()
        newDict.Hotkey := IniRead(setUpFile, section, "Hotkey", "Control")
        newDict.TapTap := IniRead(setUpFile, section, "TapTap", "false") = "false" ? false: true
        newDict.TapTapSpeed := IniRead(setUpFile, section, "TapTapSpeed", 350)
        IniWrite(A_WorkingDir, setUpFile, section, "WorkingFolder")
        newDict.AliasList := IniRead(setUpFile, section, "AliasList", "WorkingFolder\Lib\AliasList.ini")
        newDict.ArbBackground := IniRead(setUpFile, section, "ArbBackground", "1E1E1E")
        newDict.ArbWidth := IniRead(setUpFile, section, "ArbWidth", "320")
        newDict.ArbEditFont := IniRead(setUpFile, section, "ArbEditFont", "나눔고딕")
        newDict.ArbEditFontSize := IniRead(setUpFile, section, "ArbEditFontSize", "S18")
        newDict.ArbEditFontWeight := IniRead(setUpFile, section, "ArbEditFontWeight", "W1000")
        newDict.ArbEditColor := IniRead(setUpFile, section, "ArbEditColor", "D4D4D4")
        newDict.ArbEditBackground := IniRead(setUpFile, section, "ArbEditBackground", "1E1E1E")
        newDict.ArbListRows := IniRead(setUpFile, section, "ArbListRows", "6")
        newDict.ArbListFont := IniRead(setUpFile, section, "ArbListFont", "나눔고딕")
        newDict.ArbListFontSize := IniRead(setUpFile, section, "ArbListFontSize", "S12")
        newDict.ArbListFontWeight := IniRead(setUpFile, section, "ArbListFontSize", "W800")
        newDict.ArbListColor := IniRead(setUpFile, section, "ArbListColor", "CCCCCC")
        newDict.ArbListBackground := IniRead(setUpFile, section, "ArbListBackground", "1E1E1E")
        newDict.ArbMoveX := IniRead(setUpFile, section, "ArbMoveX", "410")
        newDict.ArbMoveY := IniRead(setUpFile, section, "ArbMoveY", "220")
        newDict.AutoHotkeyExe := IniRead(setUpFile, section, "AutoHotkeyExe", "")
        newDict.AhkFolder := IniRead(setUpFile, section, "AhkFolder", "")
        newDict.PythonExe := IniRead(setUpFile, section, "PythonExe", "")
        newDict.PythonFolder := IniRead(setUpFile, section, "PythonFolder", "")
        newDict.Editor := IniRead(setupFile, section, "Editor", "notepad.exe")
        SetUp.dict := newDict
        SetUp.isIniChanged := false
        if (newDict.AhkFolder) {
            ahk := SetUp.GetScriptPath("a.ahk")
            pos := InStr(ahk, "\", , -1)
            if (pos)
                SetUp.CreateFolder(SubStr(ahk, 1, pos - 1))
        }
        if (newDict.PythonFolder) {
            py := SetUp.GetScriptPath("a.py")
            pos := InStr(py, "\", , -1)
            if (pos)
                SetUp.CreateFolder(SubStr(py, 1, pos - 1))
        }
        ahkExe := SetUp.GetFilePath("AutoHotkeyExe")
        if (ahkExe and !FileExist(ahkExe)) {
            pos := InStr(ahkExe, "\", , -1)
            SetUp.CreateFolder(SubStr(ahkExe, 1, pos - 1))
            FileInstall("Src\AutoHotkey.v1.1.33.10_U64.bin", ahkExe, 0)
		}
    }

    static CreateFolder(folder) {
		if !FileExist(folder) {
			DirCreate(folder)
		}
	}
}
