class SetUp {
    static dict := {
        WorkingFolder : "",
        IniFile : "WorkingFolder\Lib\_SetUp\TapTap.ini",
        IniModifiedTime : "",
        AliasListModifiedTime : ""
    }

    static __new() {
        SetUp.MakeDict()
    }

    ; 탭탭이 전용 파일(*.ini, AutoHotkey.exe) 찾기
    static GetFilePath(fileName) {
        dirPath := "WorkingFolder"
        filePath := SetUp.dict.%fileName%
        if InStr(filePath, dirPath)
            filePath := StrReplace(filePath, dirPath, SetUp.dict.%dirPath%)
        return filePath
    }

    ; 탭탭이 AHK 전용 폴더에서 .ahk 파일 패스 찾기
    static GetAhkFilePath(ahkFile) {
        if InStr(ahkFile, "\") {
            filePath := ahkFile
        } else {
            dirPath := "WorkingFolder"
            ahkDir := SetUp.dict.AhkFolder
            if InStr(ahkDir, dirPath)
                ahkDir := StrReplace(ahkDir, dirPath, SetUp.dict.%dirPath%)
            filePath := ahkDir . "\" . ahkFile
        }
        return filePath
    }

    ; 탭탭이 AHK 전용 폴더에서 .py 파일 패스 찾기
    static GetPythonFilePath(pyFile) {
        if InStr(pyFile, "\") {
            filePath := pyFile
        } else {
            dirPath := "WorkingFolder"
            pyDir := SetUp.dict.PythonFolder
            if InStr(pyDir, dirPath)
                pyDir := StrReplace(pyDir, dirPath, SetUp.dict.%dirPath%)
            filePath := pyDir . "\" . pyFile
        }
        return filePath
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
        if (!SetUp.dict.WorkingFolder) {
            SetUp.dict.WorkingFolder := A_WorkingDir
        }
        setUpFile := SetUp.GetFilePath("IniFile")
        if !FileExist(setUpFile) {
            FileInstall("TapTap.ini.Default", setUpFile, 0)
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
        newDict.WorkingFolder := IniRead(setUpFile, section, "WorkingFolder", "")
        if (!newDict.WorkingFolder) {
            newDict.WorkingFolder := A_WorkingDir
            IniWrite(A_WorkingDir, setUpFile, section, "WorkingFolder")
        }
        newDict.TapTapIniFile := IniRead(setUpFile, section, "IniFile", "WorkingFolder\Lib\_SetUp\TapTap.ini")
        newDict.AliasListIniFile := IniRead(setUpFile, section, "AliasListIniFile", "WorkingFolder\Lib\_SetUp\AliasList.ini")
        newDict.ArbWidth := IniRead(setUpFile, section, "ArbWidth")
        newDict.AutoHotkey := IniRead(setUpFile, section, "AutoHotkey", "WorkingFolder\Lib\_SetUp\AutoHotkey.exe")
        newDict.AhkFolder := IniRead(setUpFile, section, "AhkFolder", "WorkingFolder\Lib\AHK")
        newDict.PythonFolder := IniRead(setUpFile, section, "PythonFolder", "WorkingFolder\Lib\Python")
        newDict.Editor := IniRead(setupFile, section, "Editor")
        SetUp.Dict := newDict
    }
}
