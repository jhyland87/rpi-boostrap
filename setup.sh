#!/env bash

# Execute via:
#   curl -s https://raw.githubusercontent.com/jhyland87/rpi-boostrap/main/hello-world.sh | bash

# TODO
# - Disable scrolling for history
#

_none="\e[0m"
_dirtyyellow="\e[38;5;142m"
_bold="\e[1m"
_nobold="\e[22m"
_red="\e[31m"

function err {
  printf "${_red}Error:${_none} %s\n" "${1}" 1>&2

  [[ -n ${2} ]] && exit ${2}

  return 1
}

# Verify this isn't root that's running the script
[[ $USER == root ]] && err "Must not be executed as root" 1

# Verify it's being executed from a sudoer
id --groups --name | grep -q 'sudo' || err "Script must be executed from sudoer" 1

which raspi-config &>/dev/null
if [[ $? != 0 ]]; then
  _err "No raspi-config bin found" 1
fi

sudo raspi-config nonint is_pione && echo -e "System is ${bold}Raspberry PI ${red}1${none}"
sudo raspi-config nonint is_pitwo && echo -e "System is Raspberry PI 2"
sudo raspi-config nonint is_pithree && echo -e "System is Raspberry PI 3"
sudo raspi-config nonint is_pifour && echo -e "System is Raspberry PI 4"
sudo raspi-config nonint is_pifive && echo -e "System is ${bold}Raspberry PI ${red}5${none}"


[[ -d ./tmp ]] || mkdir ./tmp

echo "Enabling UART for serial connections in /boot/config.txt..."
echo "enable_uart=1" >> /boot/config.txt

echo "Enabling UART for serial connections in /boot/firmware/config.txt..."
echo -e "dtparam=uart0\ndtparam=uart0_console" >> /boot/firmware/config.txt

# https://raspberrypi.stackexchange.com/questions/28907/how-could-one-automate-the-raspbian-raspi-config-setup
#raspi-config nonint do_serial 0

# Create custom SSH banner
echo -en "Creating custom banner... "
figlet -k $(raspi-config nonint get_hostname) > ./tmp/banner
echo -e "Please login..." >> ./tmp/banner
sudo cp -v ./tmp/banner /etc/banner
sudo echo "Banner /etc/banner" > /etc/ssh/sshd_config.d/banner.conf

# [[ $? == 0 ]] && echo -e "Done (/etc/ssh/sshd_config.d/banner.conf)" || err "Faild to create /etc/ssh/sshd_config.d/banner.conf"

if [[ $? == 0 ]]; then
  echo -e "Done (/etc/ssh/sshd_config.d/banner.conf)"
else
  err "Faild to create /etc/ssh/sshd_config.d/banner.conf"
fi

# Create custom shell MOTD
echo -en "Creating custom MOTD... "
[[ -f /etc/motd ]] && sudo mv /etc/motd /etc/motd.$(date +%s).bak
echo -e '\e[38;5;142m' > ./tmp/motd
figlet -k Welcome >> ./tmp/motd
echo -e '\e[0m' >> ./tmp/motd
echo -e "\nThis is my custom motd..\n" >> ./tmp/motd

sudo cp -v ./tmp/motd /etc/motd

if [[ $? == 0 ]]; then
  echo -e "Done (/etc/motd)"
else
   err "Faild to update /etc/motd"
fi


#[[ $? == 0 ]] && echo -e "Done (/etc/motd)" || err "Faild to update /etc/motd"

sudo systemctl restart sshd


#
# Update and install stuff
#
# wget   - Downloading HTTP content
# git    - Checkout repositories (eg: kiauh)
# vim    - Because its better than just vi
# htop   - Resource utilization monitor
# figlet - Banner-like program prints strings as ASCII art
# toilet - Color-based alternative to figlet (uses libcaca)
# dbar   - general purpose ASCII graphic percentage meter/progressbar
# golang - 
# TO ADD:
#   locate/updatedb
sudo apt-get update -y \
  && sudo apt full-upgrade \
  && sudo apt-get install -y wget git vim htop figlet toilet dbar golang 
  #|| err "failed to apt-get update and/or apt-get install" 1

if [[ $? != 0 ]]; then
  err "failed to apt-get update and/or apt-get install" 1
fi


echo -e "Installing Golang..."
go install github.com/guptarohit/asciigraph/cmd/asciigraph@latest 

if [[ $? != 0 ]]; then
  err "Failed"
else
cat << EOF 
export GOPATH=\$HOME/go
export PATH=\$PATH:/usr/local/go/bin:\${GOPATH}/bin
EOF
fi

#export PATH=$PATH:/usr/local/go/bin
#export GOPATH=$HOME/go

#cat <<EOF > ./test.sh && sudo install -m 0755 -o root ./test.sh /root/test.sh && rm ./test.sh
#echo "Hello, I am \$(whoami)"
#EOF
#echo -e "Regular, \e[38;5;245m245m\e[0m, \e[38;5;247m247m\e[0m, \e[38;5;250m250m\e[0m"


echo -e "\n\n${_dirtyyellow}Creating general_profie.sh...${_none}"

[[ ! -x /etc/profile.d/general_profie.sh ]] \
  && cat << EOF > ./tmp/general_profile.sh \
  && sudo install -m 0755 -o root ./tmp/general_profile.sh /etc/profile.d/general_profile.sh 
export EDITOR="vim -p"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
export HISTCONTROL="ignoreboth"
export HISTTIMEFORMAT="%d/%m/%y %T "
export GREP_COLORS=auto

alias ll="ls -Alrth"
alias lh="ls -Alrth"
alias vim="vim -p"
EOF



[[ $? == 0 ]] && echo -e "Successfully created /etc/profile.d/general_profile.sh"

[[ -x /etc/profile.d/general_profie.sh ]] && . /etc/profile.d/general_profie.sh


echo -e "\n\n${_dirtyyellow}Creating new prompt_command.sh...${_none}"

[[ ! -x /etc/profile.d/prompt_command.sh ]] && \
  cat <<EOF > ./tmp/prompt_command.sh \
  && sudo install -m 0755 -o root ./tmp/prompt_command.sh /etc/profile.d/prompt_command.sh \
  && rm ./tmp/prompt_command.sh \
  || err "Failed to implement new prompt_command.sh"
PROMPT_COMMAND=__prompt_command
__prompt_command() {
  local exitCode="\$?"
  local userSymbol="\$"

  local reset="\[\e[0m\]"
  local bld="\[\e[1m\]"
  local dim="\[\e[2m\]"
  local itl="\[\e[3m\]"
  local uln="\[\e[4m\]"
  local rev="\[\e[7m\]"

  local gray="\[\e[37m\]"
  local gray2="\[\e[38;5;247m\]"
  local gray3="\[\e[38;5;245m\]"
  local gray4="\[\e[38;5;243m\]"
  local gray5="\[\e[38;5;240m\]"

  local red="\[\e[38;5;160m\]"

  #local green="\[\e[0;32m\]"
  local green="\[\e[38;5;148m\]"
  local dkred="\[\e[31m\]"
  local blue="\[\e[0;34m\]"
  #local yellow="\[\e[38;5;226m\]"
  local yellow="\[\e[33m\]"

  local chkmark="\342\234\223"
  local xmark="\342\234\227"
  local usercolor=\${green}
  local usersymbol='\$'

  local paren_l="\${reset}\${gray4}(\${reset}"
  local paren_r="\${reset}\${gray4})\${reset}"

  local brack_l="\${reset}\${gray4}[\${reset}"
  local brack_r="\${reset}\${gray4}]\${reset}"

  local cbrace_l="\${reset}\${gray4}{\${reset}"
  local cbrace_r="\${reset}\${gray4}}\${reset}"

  if [[ \${UID} == 0 ]]; then
   usercolor=\${red}
   usersymbol='#'
  elif [[ -n \${MYCOLOR} ]]; then
   usercolor="\[\${MYCOLOR}\]"
  fi

  #export MYCOLOR="\e[38;5;226m"
  local timeSection="\${brack_l}\${gray2}\d \T\${brack_r}"
  local commandNumSection="\${cbrace_l}\${gray2}\#\${cbrace_r}"
  local userHostSection="\${usercolor}\u@\h\${reset}"
  local cwdSection="\${blue}\w\${reset}"
  local exitCodeIcon="\${green}\${chkmark}\${reset}"

  if [[ \${exitCode} != 0 ]]; then 
   exitCodeIcon="\${red}\${xmark}\${reset}"  
  fi

  local exitCodeSection="\${paren_l}\${exitCodeIcon}\${paren_r}\${reset}"

  export PS1="\${timeSection}\${commandNumSection}\${userHostSection}:\${cwdSection}\${exitCodeSection}\${gray}\${usersymbol}\${reset} "
}
EOF

[[ $? == 0 ]] && echo -e "Successfully created /etc/profile.d/prompt_command.sh"

[[ -x /etc/profile.d/prompt_command.sh ]] && . /etc/profile.d/prompt_command.sh

echo -e "\n\n${_dirtyyellow}Creating new vimrc.local...${_none}"

[[ ! -x /etc/vim/vimrc.local ]] \
  && cat << EOF > ~/vimrc.local \
  && sudo install -m 0755 -o root ~/vimrc.local /etc/vim/vimrc.local \
  || err "Failed to implement new vimrc.local"
filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
set showtabline=2

" Show line numbers
set number

let &showbreak = '↳ '
" Enabling line-wrap by default (with the '↳ ' value).
" Can be toggled with: \w
set wrap
set cpo=n
" ruler: shows the line/column number on the bottom right (as well as
" the percent of the file you're at
set ruler
" cursorline = Underlines the current line the cursor is on
" Toggle with: \c
set cursorline

" Shift left/right to iterate through tabs
map <S-Left> <Esc>:tabp<CR>
map <S-Right> <Esc>:tabn<CR>

"
" TOGGLE Shortcuts
"

" Toggle the line numbering
map \l <Esc>:let &number=!&number<CR>

" Shortcut for toggling line wrap: \w
map \w <Esc>:let &wrap=!&wrap<CR>

" Toggle the cursor/line underlining
map \c <Esc>:let &cursorline=!&cursorline<CR>

" None of the below work because I can't get the damn <S/D/C-> to work
" map <S-Tab> <Esc>:tabn<CR>
" map <S-.> i(<Esc>ea)<Esc>
" map <S-.>  <Esc>:tabn<CR>
" map <D-.> <Esc>:tabn<CR>
" map <D-,> <Esc>:tabp<CR>
" map <C-.> <Esc>:tabn<CR>
" map <C-,> <Esc>:tabp<CR>

syntax on

colorscheme desert
EOF

[[ $? == 0 ]] && echo -e "Successfully created /etc/vim/vimrc.local"


echo -en "\n\nDone"


