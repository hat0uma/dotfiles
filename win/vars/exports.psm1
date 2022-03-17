$local:exports = @{
    XDG_CONFIG_HOME = "$env:USERPROFILE\.config"
    XDG_CACHE_HOME  = "$env:USERPROFILE\.cache"
    WSLENV          = "HTTP_PROXY:HTTPS_PROXY:FTP_PROXY"
}

Export-ModuleMember -Variable exports

