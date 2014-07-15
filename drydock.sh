#!/bin/bash
#
#   Manage a docker build, potentially dropping to a shell if requested.
#

DEFAULT_CMD=${DEFAULT_CMD:-/bin/bash -l}
FAIL_AUTHOR=${FAIL_AUTHOR:-drydock debugger}

function main
{
    [ $# -gt 0 ] || usage

    logfile="${TMPDIR:-/tmp}/docker.log.$$"
    trap "$(trap -p EXIT | sed "s/^trap -- '//" | sed "s/' EXIT$/;/")
          rm -f '$logfile'" EXIT

    FAILURE_IMAGE="${FAILURE_IMAGE:-:fail}"
    while getopts "Ddkf:a:c:" opt
    do
        case "$opt" in
        f) FAILURE_IMAGE="$OPTARG";;
        k) KEEP_FAILED_WHEN_DEUBGGING=1;;
        d) DEBUG_CMD=":default:";;
        D) DEBUG_CMD="/bin/bash -l";;
        a) FAIL_AUTHOR="$OPTARG";;
        c) DEBUG_CMD="$OPTARG";;
        esac
    done
    shift $(( OPTIND - 1 ))

    image=$1; shift

    docker build -t=$image "$@" | tee "$logfile"
    if [ ${PIPESTATUS[0]} != 0 ]
    then
        fail_image="$FAILURE_IMAGE"
        if [ "${fail_image#:}" != "$fail_image" ]
        then
            fail_image="$image$fail_image"
        fi

        grep -- '--->' "$logfile" |
        grep 'Running in' | 
        tail -n -1 |
        while read _ _ _ container
        do
            echo "Failure container: $container" >&2
            docker commit -a "$FAIL_AUTHOR" \
                          -m "$(cat "$logfile")" \
                          "$container" "$fail_image"
        done

        if [ "$DEBUG_CMD" ]
        then
            echo >&2
            echo >&2 "Debugging in failed container $image:failed ($DEBUG_CMD)"
            echo >&2
            if [ "$DEBUG_CMD" = ":default:" ]
            then
                docker run -it "$fail_image"
            else
                docker run -it "$fail_image" "$DEBUG_CMD"
            fi

            if [ ! "$KEEP_FAILED_WHEN_DEBUGGING" ]
            then
                docker rmi -f "$fail_image"
            fi
        fi
    fi
}

function usage
{
    {
        echo "USAGE: $0 [options...] image-name [build-args]"
        echo
        echo "Options:"
        echo "-d -- run default image command on failure"
        echo "-D -- run specifically DEFAULT_CMD ($DEFAULT_CMD) on failure"
        echo "-c '[cmd args...]' -- Use specified command for debugging"
        echo "-f img -- use specified image for failure (defaults to :fail)"
        echo "-k -- keep failure image if debugging via -d or cmd"
        echo "-a name -- set author for fail image (defaults to $FAIL_AUTHOR)"
        echo "[cmd] [arg...] -- run this command on failure"
        echo
        echo "If failure-image starts with : then it is added to image-name"
        echo
        echo "Note that ALL build args (including -/-- stuff) go AFTER the "
        echo "image name."
    }
    exit 65

}

main "$@"

