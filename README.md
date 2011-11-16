This is my bash configuration and stuff.

## Installation: ##

1. Clone the repo to ~/environment
1. Source the file from .bashrc (and maybe .bash_profile)
1. ???
1. Profit!

In commands, this means:

```
$ cd
$ git clone git://github.com/stwalkerster/environment.git environment
$ echo ". ~/environment/bashrc" >> ~/.bashrc
```

## Explanation ##

The prompt is changed to the following:

```

[hh:mm:ss][user@host:workingdir]
$
```

If you are in a git repository, the following is the prompt

```

[hh:mm:ss][user@host:workingdir][branch][421]
$
```

The colour of the branch bit is as follows, in order of priority:

* Red: Unstaged files
* Yellow: Staged files
* Blue: Untracked files
* Green: Working directory clean

The last bit is only present if the working directory isn't clean, and is made up of three numbers, using the same meanings and colours as the above. If any number is zero, it won't be shown.