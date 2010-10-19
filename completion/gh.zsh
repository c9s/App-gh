function listghcommand()
{
    set -A reply $(gh | sed -e 's/^[ ]*//' | cut -d- -f1 )
}

compctl -K listghcommand gh
