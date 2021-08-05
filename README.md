This is my bash configuration and stuff.

## Installation: ##

1. Clone the repo
1. Source the bashrc file from .bashrc
1. ???
1. Profit!

## Explanation ##

The prompt is changed to the following:

```

[hh:mm:ss][user@host:workingdir]
bash $
```

If you are in a git repository, the following is the prompt

```

[hh:mm:ss][user@host:workingdir][branch|4|2|1]
$
```

The colour of the branch bit is as follows, in order of priority:

* Red: Unstaged files
* Yellow: Staged files
* Blue: Untracked files
* Green: Working directory clean

The last bit is only present if the working directory isn't clean, and is made up of three numbers, using the same meanings and colours as the above. If any number is zero, it won't be shown.

Other functionality:
* directory stack
* readlink
* perforce