Configuration HTPC {

    # Import the module that contains the resources we're using.
    Import-DscResource -Module PsDesiredStateConfiguration
    Import-DscResource -Module xRemoteDesktopAdmin, NetworkingDsc
    Import-DscResource -Module cChoco

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {
    
        # Software
        cChocoInstaller ChocoInstall
        {
            InstallDir = "C:\ProgramData\chocolatey"
        }

        $chocoPackages = @(
            "vlc"
            "plexmediaserver"
            "kodi"
            "steam"
            "retroarch"
        )

        ForEach($chocoPackage in $chocoPackages)
        {
            cChocoPackageInstaller "ChocoInstall$($chocoPackage)"
            {
                Name = "vlc"
                AutoUpgrade = $true
                Ensure = "Present"
                DependsOn = '[cChocoInstaller]ChocoInstall'
            }
        }
        

        # Settings
        xRemoteDesktopAdmin RemoteDesktopEnable
        {
            Ensure = "Present"
            UserAuthentication = "Secure"
        }

        Firewall FirewallAllowRdpTcp
        {
            Name = "Remote Desktop - User Mode (TCP-In)(DSC)"
            Group = "Remote Desktop"
            Ensure = "Present"
            Enabled = "True"
            Profile = ("Domain", "Private", "Public")
            Program = "%SystemRoot%\system32\svchost.exe"
            Protocol = "TCP"
            LocalPort = 3389
        }

        Firewall FirewallAllowRdpUdp
        {
            Name = "Remote Desktop - User Mode (UDP-In)(DSC)"
            Group = "Remote Desktop"
            Ensure = "Present"
            Enabled = "True"
            Profile = ("Domain", "Private", "Public")
            Program = "%SystemRoot%\system32\svchost.exe"
            Protocol = "UDP"
            LocalPort = 3389
        }

        <# TODO: Not sure if we want this or if it's a too big security risk
        Firewall FirewallAllowRdpShadow
        {
            Name = "Remote Desktop - Shadow (TCP-In)(DSC)"
            Group = "Remote Desktop"
            Ensure = "Present"
            Enabled = "True"
            Profile = ("Domain", "Private", "Public")
            Program = "%SystemRoot%\system32\RdpSa.exe"
            Protocol = "TCP"
        }
        #>
    }
}
HTPC