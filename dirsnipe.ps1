Function Banner {
    Write-Output "
       _ _             _         
     _| |_|___ ___ ___|_|___ ___ 
    | . | |  _|_ -|   | | . | -_|
    |___|_|_| |___|_|_|_|  _|___|
                        |_|      
    Author: Gr1mmie
    "
}

Function Write-Good { 
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$strinput 
    ) 

    Write-Host $strinput -ForegroundColor 'Green'
}

Function Write-Bad  { 
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$strinput
    ) 

    Write-Host $Global:ErrorLine $strinput -ForegroundColor 'red' 
 }

Function Write-Info {
    param( 
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$strinput
    ) 

    Write-Host  $strinput -ForegroundColor 'yellow' 
}

Function RobotsFetch {

    param ( 
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [OutputType([String])]$PageContent
    )

    try{
        $req = Invoke-WebRequest "$full_addr/robots.txt"
        return $req.Content
    } catch [Net.WebException] {
        Write-Bad " `n[-] URL failed to resolve. Exitting..."
        exit 0
    }
}

# fetch all xml files and put into new array
Function SitemapCrawl {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Sitemap,

        [Parameter(Mandatory=$true)]
        [string[]]$Disallow,

        [OutputType([string[]])]$SitemapDirs,

        [OutputType([string[]])]$SitemapArr
    )

    [string[]]$SitemapArr = $Sitemap
    [string[]]$SitemapDirs = @()

    foreach($sm in $Sitemap){
        ([xml](Invoke-WebRequest $sm).Content) | Select-Object -ExpandProperty sitemapindex | Select-Object -expand sitemap | Select-Object -Expand loc | 
            ForEach-Object { 
                $SitemapArr += $_
                if($_ -like "*.xml"){
                   $SitemapDirs += (([xml](Invoke-WebRequest $_).Content) | Select-Object -ExpandProperty urlset | Select-Object -ExpandProperty url | Select-Object -expand loc)
                } else {    
                             
                }
            }
    }

    return $SitemapDirs, $SitemapArr
}

# add contents of robots to arrays
Function RobotsParse {
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
Function RobotsPrint {
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$Directories,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Sitemaps
    )

    Write-Output "`n[+] Sitemap(s):"
    foreach($entry in $Sitemaps) { Write-Good "$entry" }
    Write-Output "`n[+] Dirs Found:"
    foreach($entry in $Directories) { Write-Good "$schema$site$entry" }
    
}

Function SitemapCrawlPrint {
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$Directories,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Sitemaps
    )

    Write-Output "`n[+] Sitemap(s):"
    foreach($entry in $Sitemaps) { Write-Good "$entry" }
    Write-Output "`n[+] Dirs Found:"
    foreach($entry in $Directories) { Write-Good "$entry" }
    
}

Function Invoke-Scrape {

    param(
        [Parameter(Mandatory=$true)]
        [string]$Site,

        [Parameter(Mandatory=$false)]
        [bool]$Secure = $false,

        [Parameter(Mandatory=$false)]
        [bool]$SitemapCrawl = $false
    )

    if(-not $Secure){ 
        $schema = "http://" 
    } else { $schema = "https://" }

    $full_addr = "$schema$site"

    $out = RobotsFetch -Url $full_addr
    
    if(-not $SitemapCrawl) { 
        Write-Info "[*] Sitemap crawl: off"
        $directories,$sitemap = RobotsParse -PageContent $out -Disallow $disallow -Sitemap $sitemap 
        RobotsPrint -Directories $directories -Sitemaps $sitemap
    } else { 
        Write-Info "[*] Sitemap crawl: on"
        $disallow,$sitemap = RobotsParse -PageContent $out -Disallow $disallow -Sitemap $sitemap
        $SitemapDirs,$SitemapArray = SitemapCrawl -Disallow $disallow -Sitemap $sitemap

        SitemapCrawlPrint -Directories $SitemapDirs -Sitemaps $SitemapArray
    }
    

}

Banner

[string]$site = Read-Host -Prompt " Enter site: "

Invoke-Scrape -Site $site -Secure $true -SitemapCrawl $true
