# Repository Metadata and Package Downloader

This PowerShell script is designed to automate the process of downloading repository metadata and packages based on the provided `repomd.xml` file URL. It's particularly useful for managing and mirroring repository data locally or in disconnected environments.

## Features

- Prompts the user for the URL to the repository's `repomd.xml` file.
- Automatically determines the base URL of the repository.
- Downloads `repomd.xml` and parses it to find the location of the primary dataset.
- Downloads and extracts the primary dataset to identify package locations.
- Downloads each package, preserving the repository's directory structure locally.

## Prerequisites

Before running the script, ensure you have the following installed on your system:

- PowerShell (5.1 or later recommended)
- 7-Zip: The script assumes that 7-Zip is installed at `C:\Program Files\7-Zip\7z.exe` for extracting `.gz` files. Make sure 7-Zip is installed and the path to the executable is correct in the script.

## Usage

1. Open PowerShell and navigate to the directory containing the script.
2. Run the script by typing `.\scriptName.ps1`, where `scriptName.ps1` is the name you've saved the script as.
3. When prompted, enter the full URL to the `repomd.xml` file of the repository you wish to download metadata and packages from.

The script will then proceed to download and organize the repository data into the specified local directories.

## Customization

You can customize the following variables within the script to suit your needs:

- `$localMetadataDir`: Local directory path for storing downloaded metadata.
- `$localPackagesDir`: Local directory path for storing downloaded packages.

Ensure these directories exist or are accessible to the script for writing.

## Known Limitations

- The script assumes a specific structure of the repository metadata (`repomd.xml` located within a `repodata` directory).
- It is tailored for repositories using the metadata format specified by `http://linux.duke.edu/metadata/repo`.

## Contributing

Feel free to fork this project and submit pull requests for any improvements or fixes. For major changes, please open an issue first to discuss what you would like to change.

## License

MIT License

Copyright (c) [2024] [Derelicity17]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Please make sure to update tests as appropriate!

