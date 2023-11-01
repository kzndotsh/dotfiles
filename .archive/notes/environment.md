# Environment notes

https://wiki.archlinux.org/title/environment_variables
https://wiki.gentoo.org/wiki/Handbook:X86/Working/EnvVar
https://help.ubuntu.com/community/EnvironmentVariables


---

/etc/environment
- Used by the pam_env module and is shell agnostic so scripting or glob expansion cannot be used. The file only accepts variable=value pairs.

/etc/profile
- Initializes variables for login shells only. It does, however, run scripts (e.g. those in /etc/profile.d/) and can be used by all Bourne shell compatible shells.

Shell specific configuration files
- Global configuration files of your shell, initializes variables and runs scripts. For example Bash#Configuration files (e.g. ~/.bashrc) or Zsh#Startup/Shutdown files (e.g. ~/.zshrc).

---

Per Xorg session

The procedure for modifying the environment of the Xorg session depends on how it is started:

    Most display managers source xprofile.
    startx and SLiM execute xinitrc.
    XDM executes ~/.xsession; see XDM#Defining the session.
    SDDM additionally sources startup scripts for login shells, like ~/.bash_profile for bash or ~/.zprofile and ~/.zlogin for zsh. [2]

Though the end of the script depends on which file it is, and any advanced syntax depends on the shell used, the basic usage is universal:

~/.xprofile, ~/.xinitrc, or ~/.xsession

...
export GUI_VAR=value
...

---

Per Wayland session

Since Wayland does not initiate any Xorg related files, GDM and KDE Plasma source systemd user environment variables instead.

~/.config/environment.d/envvars.conf

GUI_VAR=value

---

If your display manager sources startup scripts like ~/.bash_profile and you want to use environment.d, you can source it like so:

~/.bash_profile

# use systemd-environment-d-generator(8) to generate environment, and export those variables
export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs)

