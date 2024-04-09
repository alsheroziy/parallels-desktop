# Parallels Desktop Crack
Crack for Parallels Desktop 19.0.0-54570

✅ ARM64<br>
✅ x86_64<br>
✅ Network<br>
✅ USB<br>
✅ System Integrity Protection (SIP)
## Usage
1. Install Parallels Desktop:<br>
   https://download.parallels.com/desktop/v19/19.0.0-54570/ParallelsDesktop-19.0.0-54570.dmg
3. Sign out your'e account
4. `chmod +x install.sh && chmod +x Launch\ Parallels.command && sudo ./install.sh`
5. Double click `Launch Parallels.command`

You will always need to use this launcher as a workaround to prevent signature errors from occurring. However, if you are a developer with permission to use com.apple.vm.* or are willing to disable System Integrity Protection, there is a better approach available.
### Operation not permitted
Enable `System Preferences ▸ Security & Privacy ▸ Privacy ▸ Full Disk Access`
### codesign error
Ensure xcode command line tools installed. Install it with using the command `xcode-select --install`.

Check installation with `xcode-select -p`, which will output `/Library/Developer/CommandLineTools` or `/Applications/Xcode.app/Contents/Developer`.
## Hosts
You also wan't too block Parallels Servers.
```
127.0.0.1 download.parallels.com
127.0.0.1 update.parallels.com
127.0.0.1 desktop.parallels.com
127.0.0.1 download.parallels.com.cdn.cloudflare.net
127.0.0.1 update.parallels.com.cdn.cloudflare.net
127.0.0.1 desktop.parallels.com.cdn.cloudflare.net
127.0.0.1 www.parallels.cn
127.0.0.1 www.parallels.com
127.0.0.1 www.parallels.de
127.0.0.1 www.parallels.es
127.0.0.1 www.parallels.fr
127.0.0.1 www.parallels.nl
127.0.0.1 www.parallels.pt
127.0.0.1 www.parallels.ru
127.0.0.1 www.parallelskorea.com
127.0.0.1 reportus.parallels.com
127.0.0.1 parallels.cn
127.0.0.1 parallels.com
127.0.0.1 parallels.de
127.0.0.1 parallels.es
127.0.0.1 parallels.fr
127.0.0.1 parallels.nl
127.0.0.1 parallels.pt
127.0.0.1 parallels.ru
127.0.0.1 parallelskorea.com
127.0.0.1 pax-manager.myparallels.com
127.0.0.1 myparallels.com
127.0.0.1 my.parallels.com
```
Parallels Desktop will uncomment these, therefore one needs to lock the hosts file:
`sudo chflags uchg /etc/hosts && sudo chflags schg /etc/hosts`
### OS download
You will not be able to download operating systems in the Control Center anymore. Comment these out to get this functionality:
```
# 127.0.0.1 download.parallels.com
# 127.0.0.1 desktop.parallels.com
# 127.0.0.1 download.parallels.com.cdn.cloudflare.net
# 127.0.0.1 desktop.parallels.com.cdn.cloudflare.net
```
