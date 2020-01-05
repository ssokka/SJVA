# UTF-8 / CRLF
# PS	powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -F .\KLiveCustomEditTool.ps1

Write-Host ""

$title = "SJVA >> KLive >> Custom 편집"
$host.ui.RawUI.WindowTitle = $title

# 변수
$dbFile = $Args[0]
$dbTable = "plugin_klive_custom"
$chName = $Args[1]
$chNumber = $Args[2]
$chGroup = $Args[3]
$process = [System.Diagnostics.Process]::GetCurrentProcess()
$eVal = $false

# 함수 - 현재 라인 삭제
function ClearLine {
	Write-Host -NoNewline "`r"
	1..($Host.UI.RawUI.BufferSize.Width - 1) | ForEach-Object { Write-Host -NoNewline " " }
	Write-Host -NoNewline "`r"
}

# 도움말
if ($Args[0] -eq "/?" -or $Args.Count -ne 4) {
	Write-Host -ForegroundColor yellow "[사용] $($process.ProcessName).exe `"SJVA DB 파일 경로`" `"채널`" `"번호`" `"그룹`""
	Write-Host -ForegroundColor yellow "[예시] $($process.ProcessName).exe `"D:\SJVA\data\db\sjva.db`" `"EBS`" `"3`" `"지상파`""
	exit
}

# DB 파일 확인
if (-not(Test-Path -Path "$dbFile")) {
	Write-Host -ForegroundColor Red "[오류] $dbFile 파일이 존재하지 않습니다."
	exit
}

# sqlite3 다운로드 및 확인
$exe = "sqlite3.exe"
$sql = [System.IO.Path]::GetDirectoryName($($process.MainModule.FileName)) + "\$exe"
if (-not(Test-Path -Path "$sql")) {
	$str = "$exe 다운로드"
	Write-Host -NoNewline "[실행] $str 중..."
	try {
		(New-Object System.Net.WebClient).DownloadFile("https://github.com/ssokka/Windows/raw/master/tools/$exe", "$sql")
	} catch [System.Net.WebException],[System.IO.IOException] {
		$eVal = $true
		$eStr = $_.Exception.Message
	} catch {
		$eVal = $true
		$eStr = "알 수 없는 오류가 발생하였습니다."
	}
	if (-not(Test-Path -Path "$sql")) {
		$eVal = $true
		$eStr = "$sql 파일이 존재하지 않습니다."
	}
	ClearLine
	if ($eVal) {
		Write-Host -ForegroundColor Red "[실패] $str"
		Write-Host -ForegroundColor Red "[오류] $eStr"
		exit
	} else {
		Write-Host "[완료] $str"
	}
}

# 채널 이름 확인
$str = "$title >> Name = $chName"
Write-Host -NoNewline "[확인중] $str"
$cmd = @"
"$sql" "$dbFile" "select * from $dbTable where title = '$chName';"
"@
$query = (cmd /c $cmd 2`>`&1)
ClearLine
if ($query -eq $null) {
	Write-Host -ForegroundColor Red "[오류] $str 채널이 존재하지 않습니다."
	exit
}

# 채널 그룹 to HEX
foreach ($item in $chGroup.ToCharArray()) {
	$hex = $hex + "\u" + [System.String]::Format("{0:X4}", [System.Convert]::ToUInt32($item)).ToLower()
}

# DB 적용
$str = "$str | Number = $chNumber | Group = $chGroup"
Write-Host -NoNewline "[적용중] $str"
$cmd = @"
"$sql" "$dbFile" "update $dbTable set json = '{"""group""": """$hex""", """group2""": """$hex"""}', number = '$chNumber' where title = '$chName';"
"@
$query = (cmd /c $cmd 2`>`&1)
ClearLine
if ($query -eq $null) {
	Write-Host -ForegroundColor blue "[적용] $str"
} else {
	Write-Host -ForegroundColor Red "[실패] $str"
	Write-Host -ForegroundColor Red "[오류] $query"
}

exit
