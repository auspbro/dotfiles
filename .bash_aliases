#########################################################
# below is my aliases and functions
#########################################################

## directory start
alias ..='cd ..'
alias ...="cd ../.."
alias ....="cd ../../.."
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias .6='cd ../../../../../..'
alias -- -='cd -'
alias vi='vim'
alias si='sys-info'

## file access start
alias l1='ls -1'
alias lss="ls | xargs -i du -sh ./{} | sort -rh"
alias lsr="ls -R | grep :$ | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias lsd="ls -d */"


function ext() {
    for i in "$@"; do
        if [ -f "${i}" ] ; then
          case "${i}" in
            *.tar.bz2)   tar xjvf "${i}"     ;;
            *.tar.gz)    tar xzvf "${i}"     ;;
            *.tar.xz)    xz -d "${i}" && tar xvf $(echo ${i} | sed 's/\.xz$//' ) ;;
            *.bz2)       bunzip2 "${i}"      ;;
            *.rar)       unrar e "${i}"      ;;
            *.gz)        gunzip "${i}"       ;;
            *.tar)       tar xvf "${i}"      ;;
            *.tbz2)      tar xjvf "${i}"     ;;
            *.tgz)       tar xzvf "${i}"     ;;
            *.zip)       unzip "${i}"        ;;
            *.Z)         uncompress "${i}"   ;;
            *.7z)        7z x "${i}"         ;;
            *.xz)        xz -d "${i}"        ;;
            *.rpm)       extract_rpm "${i}"  ;;
            *.deb)       extract_deb "${i}"  ;;
            *.apk)       apktool -f d "${i}" ;;
            *.jar)       extract_jar "${i}"  ;;
            *)     echo "'${i}' cannot be extracted via extract()";;
             esac
         else
             echo "'${i}' is not a valid file"
         fi
     done
}

## system information
function sys-info() {

echo -e "\n"
echo -e "Welcome to $(grep "PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"'):\n"
echo -e "Kernel: \t$(uname -r)"
echo -e "CPU: \t\t$(lscpu | grep 'Model name' | sed 's/^.*:\W*//')"
echo -e "Hostname: \t$(hostname)"
echo -e "Memory: \t$(free -h | grep 'Mem:' | awk '{print $2}')"
echo -e "IP Addr: \t$(ip addr show | awk '/inet /{print $2}' | cut -d/ -f1 | grep -v '127.0.0.1' | head -1)"
echo -e "Login Users: \t$(users | wc -w)"
#echo -e "System information as of time: \t$(date)\n"
if [ "$whoami" = "root" ]
then
    echo -e "\n"
else
    echo -e "To run a command as administrator(user \"root\"),use \"sudo <command>\"."
fi

}
# sys-info


## Process start
alias path='echo -e ${PATH//:/\\n}'
alias watch-cpu="watch -n1 'ps aux | grep -v PID | sort -nrk +3 | head -25'"
alias watch-mem="watch -d -n1 'ps aux | grep -v PID | sort -nrk +4 | head -25'"

## network start
alias wget='wget -c --no-check-certificate'
alias wget-all='wget --no-check-certificate -c -r -np -k -L -p -nc'

# alias www='python -m SimpleHTTPServer 8888'
function www() {
    local port=$1
    if [ -z ${port} ]; then
        port=8888
    fi
    if ( type python3 &> /dev/null ); then
        python3 -m http.server ${port}
    else
        python -m SimpleHTTPServer ${port}
    fi
}


alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
complete -o default -o nospace -F __git_wrap__git_main dot
