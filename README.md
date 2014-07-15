=======
drydock
=======

== drydock.sh

Simple controller script/image to manage building docker images, handling
failure gracefully.

== Installation

Copy or symlink drydock.sh into your path.  Assuming you have a ~/bin/ that
is part of your path here is an example:

$ chmod +x drydock.sh
$ ln -sf $PWD/drydock.sh $HOME/bin/

== Usage

    drydock image-name

Does a normal docker build with image-name.

    drydock image-name --rm=false

Same thing with options.

    drydock -f :whoops image-name

If build fails, use image-name:whoops instead of the default image-name:fail.

