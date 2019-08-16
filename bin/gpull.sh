#!/bin/bash -x
# used to pull checkout query or cherrypick changes from gerrit in workspace

############################## config ##############################

GIT_USER=qinsl0106
GERRIT_SSH_URL=$GIT_USER@192.168.65.19
GERRIT_SSH_PORT=29418

############################## functions ##############################

function syntax() {
    echo
    echo "syntax: gpull <cp|co|p|q> <change> [<change>...]"
    echo " gpull cp 111 112 113 114"
    echo
    echo "syntax: gpull <cp|co|p|q> --"
    echo " gpull cp --"
    echo " <copy and paste a bunch of XYZ https://..gerrit.com/111 XYZ>"
    echo " <copy and paste a bunch of XYZ https://..gerrit.com/112 XYZ>"
    echo " ..."
    echo " ctrl-d"
}

function emphasize() {
    echo -n "*** "
}

function regular() {
    echo -n "    "
}

function deemphasize() {
    echo -n "--- "
}

function sub_change() {
    local inchange=$1
    if [[ $inchange =~ refs\/changes ]]; then
        inchange=$(echo $inchange| sed 's/refs\/changes\/[0-9]\+\///')
    fi
    echo "$inchange"
}

function apply_change() {
    app_patch=0
    # check for patch number
    p="^[0-9]+"
    # hack: take out refs/changes even though we would use it later
    chgnum=$(sub_change $chgnum)

    if [[ $chgnum =~ [0-9]+/ ]]; then
        ref=$chgnum
        chgnum=$(echo $chgnum| sed 's/\/[0-9]\+//')
        ref=$(echo $ref| sed 's/^[0-9]\+\///')
        app_patch=1
    fi

    result=$(ssh -p ${GERRIT_SSH_PORT} ${GERRIT_SSH_URL} gerrit query --current-patch-set change:$chgnum)
    change=$(echo "$result" | grep " ref: " | sed 's/ ref: //g')

    # use different patch number
    if [ "$app_patch" == "1" ]; then
        change=$(echo $change |sed "s|/\([0-9]\+\)$|/$ref|")
        echo "INFO: using patch number $change"
    fi

    if [ "$change" == "" ]; then
        echo "No change"
        rc=1
        pdir="unknown"
    else
        proj=$(echo "$result" | grep " project: " | sed 's/ project: //g' | sed 's/ //g')
        if [ "$proj" = "platform/manifest" ]; then
            # explicit handling of manifest since it is not in repo project list
            pdir=.repo/manifests
        else
            pdir=$(repo list $proj | awk '{print $1}') #don't use "" to remove blank in project
        fi

        pushd $pdir
        echo "cd $pdir" >> ${CHERRY_PICKED_FILE}
        emphasize
        echo -n "Project $proj -> $pdir "
        cmdout=
        if [ $cmd == "p" ]; then
            echo "(pull $change)"
            deemphasize
            cmdout=$(git pull ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change)
            rc=$?
            OUTPUT="git pull ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change"
        elif [ $cmd == "co" ]; then
            echo "(checkout $change)"
            deemphasize
            git fetch  ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change && git checkout FETCH_HEAD
            rc=$?
            OUTPUT="git fetch ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change && git checkout FETCH_HEAD"
        elif [ $cmd == "q" ]; then
            regular
            rc=0
            echo "$result"
        else
            echo "(cherry-pick $change)"
            deemphasize
            cmdout=$(git fetch ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change && git cherry-pick --allow-empty FETCH_HEAD 2>&1)
            rc=$?
            OUTPUT="git fetch ssh://$GERRIT_SSH_URL:${GERRIT_SSH_PORT}/$proj $change && git cherry-pick --allow-empty FETCH_HEAD"
        fi
        popd
    fi
    echo "cmdout=$cmdout"

    regular
    if [ $rc -ne "0" ]; then
        if [[ $cmdout =~ "nothing to commit" ]]; then
            echo "WARNING: empty change"
        elif [[ $cmdout =~ "allow-empty" ]]; then
            echo "WARNING: allow empty change"
        else
            echo -e "\n\n*** failed at gerrit $chgnum in $pdir"
            failed=1
        fi
    else
        echo $OUTPUT >> ${CHERRY_PICKED_FILE}
        echo "cd -" >> ${CHERRY_PICKED_FILE}
    fi
}


############################## main ##############################

if [ $# -lt 2 ]; then
    syntax
    exit
fi

cmd=$1
if [ "$cmd" != "cp" -a "$cmd" != "co" -a "$cmd" != "p" -a "$cmd" != "q" ]; then
    echo "gpull: BAD COMMAND: $cmd"
    syntax
    exit
fi

failed=0

shift

if [ "$1" == "--" ]; then
    echo -e "\ncopy and paste gerrit list here then ctrl-d\n"
    readarray -n 0 inputstr
    chgs=$(echo "${inputstr[*]}" | awk '{match($0, ".*/(#/c/)*([[:digit:]]+)",a); b = b " " a[2]; } END { printf("%s", b); }')
    echo "Changes: $chgs"
else
    chgs=$*
fi

LIST=$chgs
[[ -e cherry_picked.sh ]] && rm cherry_picked.sh
touch cherry_picked.sh
chmod +x cherry_picked.sh

CHERRY_PICKED_FILE="`pwd`/cherry_picked.sh"


export rest="$chgs"
for chg in $chgs; do
    chgnum=$chg
    if [ ! "$chgnum" == "" ]; then
        apply_change
        rest=$(echo "$rest" |sed "s|$chg||" |sed "s| \+| |g")
        echo "INFO: TODO: $rest, $chg"
    fi
    if [ $failed == "1" ]; then
        shift

        if [ "$KEEPGOING" == "1" ]; then
            echo WARNING: KEEPGOING: FAILED: $chg
            echo Resetting and keep going
            git reset --hard HEAD
            failed=0
        else
            if [[ ! "$rest" =~ "[:digit:]+" ]]; then
                echo "ERROR: failure found; after fixing issue, resume with"
                echo " gpull $cmd $rest"
            fi
            exit 1
        fi
    fi
    regular
done

echo "All changes applied successfully"
exit 0
