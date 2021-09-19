import os
import pyautogui as pag
import win32api


z_setup = 'z:\\SetUp\\_Python'


def wait_until_find_mark(png_file):
	'''
	화면에서 png_file 찾기
	찾을 때까지, 3초마다 영원히
	:param png_file:
	:return:
	'''
	image_dir = os.path.join(os.getcwd(), 'Lib\\Python\\RPA\\Image')
	while True:
		elem = pag.locateOnScreen(os.path.join(image_dir, png_file), confidence=0.9)
		if elem:
			pag.click(elem)
			break
		pag.sleep(3)


def maximize_sourcetree():
	'''
	소스트리 최대화: 화면에서 png_file 찾기 위해
	:return:
	'''
	while True:
		wins = pag.getWindowsWithTitle('Sourcetree')
		if wins:
			win = wins[0]
			if not win.isActive:
				win.activate()
				for _ in range(10):
					pag.sleep(0.2)
					if win.isActive:
						break
			if not win.isMaximized:
				win.maximize()
				for _ in range(10):
					pag.sleep(0.3)
					if win.isMaximized:
						break
			break
		else:
			pag.sleep(3)


def run_sourcetree():
	'''SourceTree 실행'''
	sourcetree = r'c:\Users\rtos9er\AppData\Local\SourceTree\SourceTree.exe'
	wins = pag.getWindowsWithTitle('Sourcetree')
	if wins:
		win = wins[0]
		if not win.isActive:
			win.activate()
	else:
		win32api.WinExec(sourcetree)
	pag.sleep(3)


def clone_z_setup():
	run_sourcetree()
	wait_until_find_mark('SourceTree.png')	# SourceTree 화면 찾기
	maximize_sourcetree()	# SourceTree 최대화
	# 새 복제/생성
	pag.hotkey('ctrl', 'n')
	pag.sleep(3)
	pag.click(131, 111)	# Remote
	wait_until_find_mark('SourceTree_GitHub.png')	# GitHub
	pag.click(1981, 339)	# 새로 고침
	wait_until_find_mark('SourceTree_GitHub_SetUp.png')	# 00_SetUp 찾기
	# print(pag.position())	# (897, 418)	# 00_SetUp 위치
	pag.move(1071, 22)	   	# (1968, 440)	# Clone 클릭
	pag.click()
	pag.sleep(3)
	pag.click(757, 410)	# 탐색 클릭
	wait_until_find_mark('SourceTree_RamDrive.png')	# RamDriver 클릭
	wait_until_find_mark('SourceTree_Z_SetUp.png')	# Z:\SetUp 클릭
	wait_until_find_mark('SourceTree_Folder.png')	# 폴더 선택
	wait_until_find_mark('SourceTree_Clone.png')	# 클론 클릭
	pag.click(2472, 16)	# Restore Window


if __name__ == '__main__':
	if not os.path.exists(z_setup):
		clone_z_setup()
