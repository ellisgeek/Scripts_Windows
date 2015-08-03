Function Set-Wallpaper {
    <#
    .SYNOPSIS Set wallpaper
    .PARAMETER Path
        Path to image that will be set as wallpaper
    .PARAMETER Style
        Wallpaper display style, One of 'Center', 'Stretch', 'Fill', 'Tile', or 'Fit'.
    .LINK https:/github.com/ellisgeek/Scripts_Windows
    .NOTE
        ==================================== About ====================================
        ===============================================================================
        	Author: Elliott Saille <me@esaille.me>
        	Date: July 13, 2015
        =================================== LICENSE ===================================
        ===============================================================================
            This Source Code Form is subject to the terms of the Mozilla Public License,
            v. 2.0. If a copy of the MPL was not distributed with this file, You can
            obtain one at http://mozilla.org/MPL/2.0/.
        ===============================================================================
    #>
	Param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({Test-Path (Convert-Path $_) -PathType 'Leaf'})]
		[String]$Path,
		[ValidateSet('Center', 'Stretch', 'Fill', 'Tile', 'Fit')]
		[String]$Style = 'Fill'
	)
	Try {
		if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
			add-type @"
			using System;
			using System.Runtime.InteropServices;
			using Microsoft.Win32;
			namespace Wallpaper
			{
			  public enum Style : int
			  {
			      Tile, Center, Stretch, Fit, Fill, NoChange
			  }
			 
			 
			  public class Setter {
			     public const int SetDesktopWallpaper = 20;
			     public const int UpdateIniFile = 0x01;
			     public const int SendWinIniChange = 0x02;
			 
			     [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
			     private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
			     
			     public static void SetWallpaper ( string path, Wallpaper.Style style ) {
			        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
			       
			        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
			        switch( style )
			        {
						case Style.Tile :
			    key.SetValue(@"WallpaperStyle", "1") ;
			    key.SetValue(@"TileWallpaper", "1") ;
			    break;
			  case Style.Center :
			    key.SetValue(@"WallpaperStyle", "0") ;
			    key.SetValue(@"TileWallpaper", "0") ;
			    break;
			  case Style.Stretch :
			    key.SetValue(@"WallpaperStyle", "2") ;
			    key.SetValue(@"TileWallpaper", "0") ;
			    break;
						case Style.Fit :
			    key.SetValue(@"WallpaperStyle", "6") ;
			    key.SetValue(@"TileWallpaper", "0") ;
			    break;
			  case Style.Fill :
			    key.SetValue(@"WallpaperStyle", "10") ;
			    key.SetValue(@"TileWallpaper", "0") ;
			    break;
			 case Style.NoChange :
			    break;
			        }
			        key.Close();
			     }
			  }
			}
"@ -ErrorAction Stop
		}
	} Catch {
		Write-Warning -Message "Wallpaper not changed because $($_.Exception.Message)"
    }
    #We set the wallpaper twice so that the scaling mode is set correctly. It works so ¯\_(ツ)_/¯
	[Wallpaper.Setter]::SetWallpaper( (Convert-Path $Path), $Style )
	[Wallpaper.Setter]::SetWallpaper( (Convert-Path $Path), $Style )
}
