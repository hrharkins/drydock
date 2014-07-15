=======
drydock
=======

Simple controller script/image to manage building docker images, handling
failure gracefully.

## Installation

Copy or symlink drydock.sh into your path.  Assuming you have a ~/bin/ that
is part of your path here is an example:

    chmod +x drydock.sh
    ln -sf $PWD/drydock.sh $HOME/bin/

## Usage

    drydock image-name

Does a normal docker build with image-name.

    drydock image-name --rm=false .

Same thing with options.  Note the need to add the "." when providing
options.

    drydock -f :whoops image-name

If build fails, use image-name:whoops instead of the default image-name:fail.

    drydock -d image-name

Build and use the default debugger on failure (/bin/bash typically)

    drydock -D image-name

Explicitly use /bin/bash -l on failure (handy for some ubuntu images)

    drydock -c 'ls /test' image-name

Run ls /test on failure.

    drydock -kd image-name

Debug and don't delete the failure image when done debugging.

    drydock -a 'Me' image-name

Use a specific author instead of "drydock debugger" for the author name.

