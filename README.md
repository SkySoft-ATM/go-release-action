# go-release-action

⚠️This action is DEPRECATED and this repository is archived.
This action uses a token to authenticate to Google Cloud, which is not recommended.
It should be changed to use workload identity federation instead.

# Usage
<!-- start usage -->
```yaml
- uses: SkySoft-ATM/go-release-action@v1
  with:
    # GCloud token in base 64
    gcloud_token:  ${{ secrets.MY_GCLOUD_TOKEN_SECRET }}
  
    # Github user
    github_user:  ${{ secrets.MY_GITHUB_USER }}
    
    # Github token
    github_token:  ${{ secrets.MY_GITHUB_TOKEN }}

    # Folder where the main go function is located
    # Default:  './main/'
    go_main_folder: '.'

    # Description
    app_description: 'an application offering a web GUI to trigger github actions'

    # GKE Project
    # Default:  sk-private-registry/skysoft-atm
    project: myProject
    
    # The repo name
    # Default: ${{ github.event.repository.name }}
    repo_name: ''
  
    # The application name (without spaces, this will be used as the binary and docker image name)
    # Default: ${{ github.event.repository.name }}
    app_name: ''
  
    # The dockerfile used to build the docker image
    # By default a generic docker file will be used. If you want more flexibility for your project, you can point to a custom dockerfile
    dockerfile: ''

    # Options for the gosec command line
    # Default: ''
    gosec_opts: '-exclude-dir=myExcludedDir'

    # Options to generate version
    # Default: 'false'
    generate_version: true

    
```
<!-- end usage -->

# Configuration of elements embedded in the docker file
If you use the default generic dockerfile provided by this action, you can add a file in your project name `dockerInclude`.
In this file you can list line by line the files and folders to include in the final docker image. By default, the `configs` and `static` folders are embedded.
