<#
	HOW TO USE THIS PROGRAM:
	
	$ExcludeList, $BackupDrivename, and $LogLocation should all be changed to whichever variables you need.
	Basically:
		$ExcludeList should be a text file for excluding directories to back up in 7-zip. If unsure about this, point it to an empty text file.
		
		$BackupDrivename this SHOULD be the name of the backup drive in Windows. You can run:
			Get-PSDrive | Select Root, Description
		to find the correct drive.
		
		$LogLocation this should be the name of a text file for this script to save a log.
		
	This script was developed on a machine running PowerShell version 5. $PSVersionTable.PSVersion will return your installed PS version. 
	This script has not been tested on any other versions of PowerShell.

#>

param([string]$ExcludeList="C:\path\to\exclude.txt", [string]$BackupDrivename="Name of Backup Drive", [string]$LogLocation="C:\path\to\log.txt");

Set-Alias 7z "C:\Program Files\7-Zip\7z.exe"


$prof=$env:UserProfile
$arch_name=(Get-Date -Format "yyyy-MM-dd").ToString()
$backup_location=(Get-PSDrive | where {$_.Description -eq $BackupDrivename}).Root

Write-Output ((Date).ToString()+" - Archiving misc folders...") | Tee-Object -FilePath $LogLocation -Append;

7z @7zArgs | Tee-Object -FilePath $LogLocation -Append;

Write-Output ((Date).ToString()+" - Archive complete...") | Tee-Object -FilePath $LogLocation -Append;

Write-Output ((Date).ToString()+" - Starting profile backup...") | Tee-Object -FilePath $LogLocation -Append;

if (-Not (Test-Path $backup_location"full.7z") -Or ((Get-ChildItem $backup_location"full.7z").LastWriteTime -lt (Date).AddDays(-30))) {
	if (Test-Path $backup_location"full.7z") {
		$last_full_date = Date((Get-ChildItem $backup_location"full.7z").LastWriteTime.ToShortDateString()) -Format "yyyy-MM-dd";
		Write-Output ((Date).ToString()+" - Archiving previous full backup... ") | Tee-Object -FilePath $LogLocation -Append;
		Move-Item $backup_location"full.7z" $backup_location$last_full_date"_full.7z";
		Write-Output ((Date).ToString()+" - Previous full backup archived... ") | Tee-Object -FilePath $LogLocation -Append;
	}
	$7zArgs = @(
		"a";
		$backup_location+"full.7z";
		$prof;
		"-xr@"+$ExcludeList;
	)
	Write-Output ((Date).ToString()+" - Recreating full profile backup... ") | Tee-Object -FilePath $LogLocation -Append;
} else {
	$7zArgs = @(
		"u";
		$backup_location+"full.7z";
		$prof;
		"-xr@"+$ExcludeList;
		"-ssw";
		"-u-";
		"-up0q3r2x2y2z0w2!"+$backup_location+$arch_name+".7z";
	)
	Write-Output ((Date).ToString()+" - Performing differential profile backup... ") | Tee-Object -FilePath $LogLocation -Append;
}
7z @7zArgs | Tee-Object -FilePath $LogLocation -Append;

Write-Output ((Date).ToString()+" - Profile backup complete... ") | Tee-Object -FilePath $LogLocation -Append;