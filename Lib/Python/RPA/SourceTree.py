import sys
import win32api

arg = sys.argv[1]
opt = option[:2].lower()
if 'se' in opt or 'su' in opt:
    win32api.WinExec(r'c:\App\Prog\Miniconda3\python.exe z:\_StartUp\ARB\RPA\SetUp.py')
elif 'st' in opt or 'sd' in opt:
    win32api.WinExec(r'c:\App\Prog\Miniconda3\python.exe z:\_StartUp\ARB\RPA\StockData.py')
elif 'mo' in opt or 'mg' in opt:
    win32api.WinExec(r'c:\App\Prog\Miniconda3\python.exe z:\_StartUp\ARB\RPA\MoneyGatherer.py')
else:
    win32api.WinExec('C:\\Users\\rtos9er\\AppData\\Local\\SourceTree\\SourceTree.exe')
