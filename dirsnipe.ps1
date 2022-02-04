function Banner {
Write-Output "
       _ _             _         
     _| |_|___ ___ ___|_|___ ___ 
    | . | |  _|_ -|   | | . | -_|
    |___|_|_| |___|_|_|_|  _|___|
                        |_|      
    Author: Gr1mmie
    "
    
}

Banner 
# var initialization
[string]$site = Read-Host -Prompt " Enter site: "
[string]$schema = "http://"
[string]$full_addr = "$schema$site"

function Write-Good { 
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$strinput 
    ) 

    Write-Host $strinput -ForegroundColor 'Green'
}

function Write-Bad  { 
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$strinput
    ) 

    Write-Host $Global:ErrorLine $input -ForegroundColor 'red' 
 }

# function to return page contents
Function Fetch {

    param ( [OutputType([String])]$PageContent )

    try{
        $req = Invoke-WebRequest "$full_addr/robots.txt"
        return $req.Content
    } catch [Net.WebException] {
        Write-Bad " `n[-] URL failed to resolve. Exitting..."
        exit 0
    }
}

# add contents of robots to arrays
Function Parse {
    param (
        [Parameter(Mandatory=$true)]
        [string]$PageContent,
        
        [AllowNull()]
        [Parameter(Mandatory=$true)]
        [string[]]$disallow,
        
        [AllowNull()]
        [Parameter(Mandatory=$true)]
        [string[]]$sitemap
    )

    $Pagearr = $PageContent.Split("`n")

    foreach($line in $Pagearr){
        if($line -like "Disallow*") { $disallow += $line.Split(" ")[1] }
        if($line -like "Sitemap*") { $sitemap += $line.Split(" ")[1] }
    } 

    return $disallow, $sitemap
}

# print out tags
Function Print {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$disallow,
        
        [Parameter(Mandatory=$true)]
        [string[]]$sitemap 
    )

    Write-Output "`n[+] Sitemap(s): `n"
    foreach($entry in $sitemap) { Write-Good "$entry" }
    Write-Output "`n[+] Dirs Found: `n"
    foreach($entry in $disallow) { Write-Good "$schema$site$entry" }
    
}

$out = Fetch

$disallow,$sitemap = Parse -PageContent $out -Disallow $disallow -Sitemap $sitemap

Print -Disallow $disallow -Sitemap $sitemap
