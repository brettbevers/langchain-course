# DevContainer Setup

## Requirements

1. IDE: VSCode
2. Environment Variables
    1. `HOME` must be defined in the host machine's environment.
        - Setting `HOME` on Windows:
        ```powershell
        [Environment]::SetEnvironmentVariable("HOME", "C:\Users\bbevers\", [EnvironmentVariableTarget]::User)
        ```
3. Verify these directories exist on host machine:
    - `$HOME/.aws`
      - will reference the host machine's `aws` credentials.
    - `$HOME/.config`
      - will reference the config directory used by Github CLI.
    - `$HOME/.ssh`
      - will reference the `.ssh` config directory.

## Features
### Unity Catalog
This DevContainer supports local use of [Unity Catalog](https://www.unitycatalog.io/).
To enable, create a file `docker/dev-box/.env` in your copy of the repository with the following content:
```
COMPOSE_PROFILES=unity-catalog
```
After starting the DevContainer, the Unity Catalog UI will be available at http://localhost:3000.
