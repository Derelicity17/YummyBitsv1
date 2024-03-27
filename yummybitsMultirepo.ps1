# Define your repositories and their repomd.xml URLs
$repositories = @(
    @{
        Name = "AppStream/x86-64";
        RepomdUrl = "https://rockylinux.mirror.digitalpacific.com.au/9.3/AppStream/x86_64/kickstart/repodata/repomd.xml"
    },
    @{
        Name = "BaseOS/x86-64";
        RepomdUrl = "https://rockylinux.mirror.digitalpacific.com.au/9.3/BaseOS/x86_64/os/repodata/repomd.xml"
    }
    # Add more repositories as needed
)

# Base directory where all repositories will be mirrored
$baseDirectory = "C:\MirroredRepos"

foreach ($repo in $repositories) {
    $repoName = $repo.Name
    $repomdXmlUrl = $repo.RepomdUrl
    $repoBaseUrl = $repomdXmlUrl -replace "repodata/repomd.xml$", "" # Extract the base URL of the repo

    # Define local paths for this repository
    $localMetadataDir = Join-Path -Path $baseDirectory -ChildPath $repoName -ChildPath "repodata"
    $localPackagesDir = Join-Path -Path $baseDirectory -ChildPath $repoName -ChildPath "packages"

    # Ensure the local directories for this repo exist
    New-Item -Path $localMetadataDir -ItemType Directory -Force
    New-Item -Path $localPackagesDir -ItemType Directory -Force

    # Download repomd.xml
    $localRepomdXmlPath = Join-Path -Path $localMetadataDir -ChildPath "repomd.xml"
    Invoke-WebRequest -Uri $repomdXmlUrl -OutFile $localRepomdXmlPath

    # Load and parse repomd.xml to find the primary.xml.gz location
    [xml]$repomdXml = Get-Content $localRepomdXmlPath
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($repomdXml.NameTable)
    $namespaceManager.AddNamespace("repo", "http://linux.duke.edu/metadata/repo")
    $primaryHref = $repomdXml.SelectSingleNode("//repo:data[@type='primary']/repo:location", $namespaceManager).getAttribute("href")
    
    # Construct the full URL for primary.xml.gz and download it
    $primaryXmlGzUrl = $repoBaseUrl + $primaryHref
    $localPrimaryXmlGzPath = Join-Path -Path $localMetadataDir -ChildPath (Split-Path -Leaf $primaryHref)
    Invoke-WebRequest -Uri $primaryXmlGzUrl -OutFile $localPrimaryXmlGzPath

    # Extract primary.xml.gz using 7-Zip (assuming 7-Zip is installed and in the system path)
    $7ZipPath = "C:\Program Files\7-Zip\7z.exe"
    & $7ZipPath e -y -o"$localMetadataDir" "$localPrimaryXmlGzPath"

    # Find the extracted primary.xml file
    $primaryXmlFile = Get-ChildItem -Path $localMetadataDir -Filter "*.xml" | Where-Object Name -like "*-PRIMARY.xml" | Select-Object -First 1
    if ($null -eq $primaryXmlFile) {
        Write-Error "Failed to find extracted primary.xml in $localMetadataDir"
        exit
    }
    $localPrimaryXmlPath = $primaryXmlFile.FullName

    # Load and parse primary.xml for package locations
    [xml]$primaryXml = Get-Content $localPrimaryXmlPath
    $namespaceManager = New-Object System.Xml.XmlNamespaceManager($primaryXml.NameTable)
    $namespaceManager.AddNamespace("c", "http://linux.duke.edu/metadata/common")
    $namespaceManager.AddNamespace("rpm", "http://linux.duke.edu/metadata/rpm")
    $packageLocations = $primaryXml.SelectNodes("//c:package/c:location", $namespaceManager) | ForEach-Object { $_.getAttribute("href") }

    # Download packages using Start-BitsTransfer
    foreach ($relativeUrl in $packageLocations) {
        $fullUrl = $repoBaseUrl + $relativeUrl
        $localFilePath = Join-Path -Path $localPackagesDir -ChildPath $relativeUrl

        # Create the directory structure for the current package if it does not exist
        $localFileDirectory = Split-Path -Path $localFilePath -Parent
        if (-not (Test-Path -Path $localFileDirectory)) {
            New-Item -Path $localFileDirectory -ItemType Directory -Force
        }

        # Use BITS to download the package
        Start-BitsTransfer -Source $fullUrl -Destination $localFilePath
        Write-Host "Downloaded package to: $localFilePath"
        }


Write-Host "Completed downloading packages for repository: $repoName"

