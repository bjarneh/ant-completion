## Ant completion

The [ant][1] completion script that comes with [Ubuntu 12.04][2] 
seems broken; this is another version which will list available
build targets and options, when you press TAB a couple of times.

### Howto

Put the file `ant-completion.bash` somewhere it gets sourced,
or source it inside a startup file (`.profile`, `.bashrc` etc).
As an example you can put it inside a folder inside your
`$HOME` directory, if you put it inside `$HOME/.bash_completion.d`
and add this section to one of your startup files:


    if [ -d "${HOME}/.bash_completion.d" ]; then
        for f in "$HOME/.bash_completion.d"/*;
        do
            . "$f"
        done
    fi


you should hopefully get some completion for ant again, you can
of course just source the script as well..

    source ant-completion.bash


[1]: http://ant.apache.org "Apache Ant Homepage"
[2]: http://ubuntu.com "Ubuntu Homepage"
