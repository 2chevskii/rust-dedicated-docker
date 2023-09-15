
[CmdletBinding()]
param (
  [ValidateSet('All', 'Vanilla', 'Oxide')]
  [string] $BuildType,
  $RustVersion,
  $OxideVersion
)

$image_repository = '2chevskii/rust-ds'
$git_repository_url = 'https://github.com/2chevskii/rust-dedicated-docker.git'


$github_api_version = '2022-11-28'
$github_api_headers = @{
  Accept                 = 'application/vnd.github+json'
  'X-GitHub-Api-Version' = $github_api_version
}

function Get-VanillaImageTags {
  param($is_latest, $version)

  $tags = @("$($image_repository):vanilla-$version")

  if ($is_latest) {
    $tags += "$($image_repository):vanilla"
    $tags += "$($image_repository):latest"
  }
}

function Get-OxideImageTags {
  param($is_latest, $version)

  $tags = @("$($image_repository):oxide-$version")

  if ($is_latest) {
    $tags += "$($image_repository):oxide"
  }

  return $tags
}

function Get-OxideRustReleases {
  $response = Invoke-WebRequest -Uri 'https://api.github.com/repos/OxideMod/Oxide.Rust/releases' -Headers $github_api_headers
  if ($response.StatusCode -ne 200) {
    throw 'Could not fetch Oxide.Rust releases from GitHub API'
  }

  $release_list = $response.Content | ConvertFrom-Json | ForEach-Object {
    return @{
      name          = $_.name
      tag           = [semver] $_.tag_name
      is_prerelease = $_.prerelease
      is_draft      = $_.draft
      created_at    = $_.created_at
      published_at  = $_.published_at
      assets        = $_.assets
    }
  }

  return $release_list
}

function Get-OxideModLatestVersion {

}

function Get-RustLatestVersion {
  $branch = 'public'


}

function Test-OxideModVersionLatest {
  $branch = 'develop'
}

Get-OxideRustReleases | Sort-Object -Property tag | Select-Object -Expand tag
| Write-Host
