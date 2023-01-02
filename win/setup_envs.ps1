Set-StrictMode -Version Latest
$envs = @{
    XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
    XDG_CACHE_HOME  = "$env:USERPROFILE\.cache"
    WSLENV          = "HTTP_PROXY:HTTPS_PROXY:FTP_PROXY"
}

function ExportEnvs([hashtable]$newEnvs)
{
    foreach ($key in $newEnvs.Keys)
    {
        [Environment]::SetEnvironmentVariable($key, $newEnvs[$key] , 'Process')
        [Environment]::SetEnvironmentVariable($key, $newEnvs[$key] , 'User')
    }
}

ExportEnvs $envs

