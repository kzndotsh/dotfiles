

#!/usr/bin/env bash



[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="Tokyo Night"
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="tokyo-night"
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
    local key="$1"; shift
    local val="$1"; shift

    if [[ "$type" == "string" ]]; then
        val="'$val'"
    fi

    "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# because dconf still doesn't have "append"
dlist_append() {
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "'$val'"
        } | head -c-1 | tr "\n" ,
    )"

    "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
    [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

    if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
        if which "$UUIDGEN" > /dev/null 2>&1; then
            PROFILE_SLUG=`uuidgen`
        fi

        if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
            DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
        else
            DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
        fi

        DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
        PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

        # copy existing settings from default profile
        $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

        # add new copy to list of profiles
        dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

        # backgroundColor = "#1a1b26";
        # foregroundColor = "#a9b1d6";
        # boldColor = "#363b54";
        # black = "#363b54";
        # blue = "#7aa2f7";
        # cyan = "#7dcfff";
        # green = "#41a6b5";
        # magenta = "#bb9af7";
        # red = "#f7768e";
        # white = "#787c99";
        # yellow = "#e0af68";
        # lightBlack = "#363b54";
        # lightBlue = "#7aa2f7";
        # lightCyan = "#7dcfff";
        # lightGreen = "#41a6b5";
        # lightMagenta = "#bb9af7";
        # lightRed = "#f7768e";
        # lightWhite = "#acb0d0";
        # lightYellow = "#e0af68";
        # palette: { black, red, green, yellow, blue, magenta, cyan, white, lightBlack, lightRed, lightGreen, lightYellow, lightBlue, lightMagenta, lightCyan, lightWhite}

        # update profile values with theme options
        dset visible-name "'$PROFILE_NAME'"
        dset palette "['#363b54', '#f7768e', '#41a6b5', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#787c99', '#363b54', '#f7768e', '#41a6b5', '#e0af68', '#7aa2f7', '#bb9af7', '#7dcfff', '#acb0d0']"
        dset background-color "'#1a1b26'"
        dset foreground-color "'#a9b1d6'"
        dset bold-color "'#a9b1d6'"
        dset bold-color-same-as-fg "true"
        dset use-theme-colors "false"
        dset use-theme-background "false"

        unset PROFILE_NAME
        unset PROFILE_SLUG
        unset DCONF
        unset UUIDGEN
        exit 0
    fi
fi

# Fallback for Gnome 2 and early Gnome 3
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# Because gconftool doesn't have "append"
glist_append() {
    local type="$1"; shift
    local key="$1"; shift
    local val="$1"; shift

    local entries="$(
        {
            "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
            echo "$val"
        } | head -c-1 | tr "\n" ,
    )"

    "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# Append profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#363b54:#f7768e:#41a6b5:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#787c99:#363b54:#f7768e:#41a6b5:#e0af68:#7aa2f7:#bb9af7:#7dcfff:#acb0d0"
gset string background-color "'#1a1b26'"
gset string foreground-color "'#a9b1d6'"
gset string bold-color "'#a9b1d6'"
gset bool   bold-color-same-as-fg "true"
gset bool   use-theme-colors "false"
gset bool   use-theme-background "false"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN