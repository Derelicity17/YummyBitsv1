# Repository Metadata and Package Downloader

These PowerShell scripts automate the process of downloading repository metadata and packages based on the provided `repomd.xml` file(s) URL. They are particularly useful for managing and mirroring repository data locally or in disconnected environments.

TLDR: download your Linux mirror on Windows!

## Features

- **Automated Metadata Download:** The script prompts the user for the URL to the repository's `repomd.xml` file(s) and then automatically determines the base URL of the repository. It proceeds to download `repomd.xml` and parses it to find the location of the primary dataset.
- **Package Download:** After extracting the primary dataset to identify package locations, the script downloads each package, preserving the repository's directory structure locally.
- **Multiple Repository Support:** The multi-repository script supports downloading metadata and packages from multiple repositories, enabling efficient management of diverse repository sources.

## Prerequisites

Before running the script, ensure you have the following installed on your system:

- PowerShell (5.1 or later recommended)
- 7-Zip: The script assumes that 7-Zip is installed at `C:\Program Files\7-Zip\7z.exe` for extracting `.gz` files. Make sure 7-Zip is installed and the path to the executable is correct in the script.

## Usage

1. Open PowerShell and navigate to the directory containing the script.
2. Run the script by typing `.\scriptName.ps1`, where `scriptName.ps1` is the name you've saved the script as.
3. Follow the prompts to provide the necessary inputs, including the URL(s) to the `repomd.xml` file(s) of the repository or repositories you wish to download metadata and packages from.

The script will then proceed to download and organize the repository data into the specified local directories. During execution, it will display detailed progress information, including the files being downloaded and their download status.

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

## Feature Requests

If you have any ideas for new features or improvements, please open an issue on the GitHub repository to discuss them. We welcome contributions and feedback from the community!

Please make sure to update tests as appropriate!
