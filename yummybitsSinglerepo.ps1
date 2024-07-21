# Prompt the user for the URL to the repomd.xml file
$repomdXmlUrl = Read-Host "Please enter the URL to the repomd.xml file"
$repoBaseUrl = $repomdXmlUrl -replace "repodata/repomd.xml$", "" # Assumes repomd.xml is at the specific location

# Define local paths for downloading the metadata and packages
$localMetadataDir = "Path\to\ExternalMedia\RepoMetadata"
$localPackagesDir = "Path\to\ExternalMedia\DownloadedPackages"

# Ensure the local directories exist
New-Item -Path $localMetadataDir -ItemType Directory -Force
New-Item -Path $localPackagesDir -ItemType Directory -Force

# Download repomd.xml
$localRepomdXmlPath = Join-Path -Path $localMetadataDir -ChildPath "repomd.xml"
Invoke-WebRequest -Uri $repomdXmlUrl -OutFile $localRepomdXmlPath

# Load and parse repomd.xml to find the primary.xml.gz location
[xml]$repomdXml = Get-Content $localRepomdXmlPath

# Assuming namespace definitions similar to Duke XML examples
$namespaceManager = New-Object System.Xml.XmlNamespaceManager($repomdXml.NameTable)
$namespaceManager.AddNamespace("repo", "http://linux.duke.edu/metadata/repo")

# Extract the href attribute for the primary dataset
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

# Define and add namespaces if necessary
$namespaceManager = New-Object System.Xml.XmlNamespaceManager($primaryXml.NameTable)
$namespaceManager.AddNamespace("default", "http://linux.duke.edu/metadata/common")
$namespaceManager.AddNamespace("rpm", "http://linux.duke.edu/metadata/rpm")

# Extract package locations
$packageLocations = $primaryXml.SelectNodes("//default:package/default:location", $namespaceManager) | ForEach-Object { $_.getAttribute("href") }

foreach ($relativeUrl in $packageLocations) {
    # Construct the full URL for the package
    $fullUrl = $repoBaseUrl + $relativeUrl

    # Determine the local path, preserving the directory structure
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

