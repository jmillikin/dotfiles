# Reasonable and short $PATH
PATH="${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Remaining settings are only for interactive shells.
if [[ -z "${PS1}" ]]; then
	return
fi

# Long-term command history, dropping duplicates. Can't use unlimited (-1)
# because MacOS bash is too old.
HISTSIZE=100000
HISTFILESIZE=1000000
HISTCONTROL=ignoredups
shopt -s histappend

# Support terminal resizing.
shopt -s checkwinsize

# Primary input prompt.
if tput setaf 1 >&/dev/null; then
	PS1='\[\e[01;32m\][\u@\h]\[\e[01;34m\][`/bin/date +%Y-%m-%d` \t]\[\e[01;34m\][\w]\[\e[00m\]\n\$ '
else
	PS1='[\u@\h][`/bin/date +%Y-%m-%d` \t][\w]\n\$ '
fi

# Update terminal window title if supported.
case "${TERM}" in
xterm*|rxvt*)
	PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
	;;
*)
	;;
esac

# Enable custom dircolor support
if [[ -x /usr/bin/dircolors ]]; then
	eval "$(dircolors -b)"
fi

# Prevent accidental forkbombs
if [[ "$(ulimit -u)" -gt 1000 || "$(ulimit -u)" -eq 'unlimited' ]]; then
	ulimit -S -u 1000
fi

# Permit ANSI color control characters to pass through less(1).
export LESS='-R'

# Default text editor.
export EDITOR='/usr/bin/vim'

# Assume UTF-8 encoding by default.
export LC_ALL='en_US.utf8'

# Signatures and identity.
export FULL_NAME='John Millikin'
export GPGKEY='0x79F3A624890F889A'
export EMAIL='john@john-millikin.com'

# Aliases
alias rm="rm -i"
alias grep="grep --color=auto"

if /bin/ls --color=auto /dev/null &>/dev/null; then
	# GNU
	alias du="du --si"
	alias df="df --si"
	alias ls="ls -p --si --color=auto"
elif [[ -f /bin/launchctl ]]; then
	# Probably MacOS
	alias ls="ls -p -G"
fi

# Local system customizations
if [[ -d "${HOME}/.bashrc.d" ]]; then
	if [[ ! -z $(ls -A "${HOME}/.bashrc.d") ]]; then
		source "${HOME}/.bashrc.d/"*
	fi
fi
