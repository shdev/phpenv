##
## The structure is lend from https://github.com/virtphp/virtphp activation scripts
##

list_php_major_versions () {
    ls -1d /usr/local/Cellar/php[0-9][0-9] | xargs -n 1 basename | grep -o '[0-9][0-9]'
}

list_php_minor_versions () {
    ls -1 "/usr/local/Cellar/php$1" | sort --version-sort -r
}


# Function to make sure used variables are removed
# before environment is setup
deactivate_php_env () {

    if [ "$PHP_ENV_NAME" ]; then
        unset PHP_ENV_NAME
    fi

    if [ "$PHP_ENV_OLD_VIRTUAL_PATH" ] ; then
        PATH="$PHP_ENV_OLD_VIRTUAL_PATH"
        export PATH
        unset PHP_ENV_OLD_VIRTUAL_PATH
    fi

    if [ "$PHP_ENV_PATH" ]; then
        unset PHP_ENV_PATH
    fi

    if [ "$PHP_ENV_COMPOSER_GLOBAL" ]; then
        export COMPOSER_HOME="$PHP_ENV_OLD_COMPOSER_HOME"
        unset PHP_ENV_OLD_COMPOSER_HOME
        unset PHP_ENV_COMPOSER_GLOBAL
    fi

    if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
        hash -r 2>/dev/null
    fi

    if [ -z "$1" ]; then

        echo "Deactivated PHPEnv current php version"
        echo ''

        php -version

        echo ''
    fi

}


activat_php_env () {

    if [ $(list_php_major_versions | grep "^$1\$" ) ]; then ;
        
    else
        echo Sorry can\'t  find your PHP version valid values are
        echo ""
        list_php_major_versions
        return 23
    fi;


    # Reset variables
    deactivate_php_env silent

    if [ "$VIRTUAL_ENV" ] ; then
        echo "You are currently running a virtualenv session: $VIRTUAL_ENV"
        echo "Please exit this session before starting a PHPEnv session."
        return 0
    fi

    # Check to see if switching PHPEnv Environments
    if [ "$PHP_ENV_NAME" ] ; then

        if [ -n "$ZSH_VERSION" ]; then
            echo "You are currently in a PHPEnv session. Do you want to switch? y/n "
            read yn
        else
            read -p "You are currently in a PHPEnv session. Do you want to switch? y/n " yn
        fi
        
        case $yn in
            NO) return 0;;
            No) return 0;;
            n) return 0;;
            no) return 0;;
            N) return 0;;
        esac
    fi

    PHP_ENV_NAME="$1"
    export PHP_ENV_NAME


    PHP_EXACT_VER=$(list_php_minor_versions $1 | head -n1)

    # Current is set when being written by install script
    PHP_ENV_PATH="/usr/local/Cellar/php$1/$PHP_EXACT_VER/bin/"
    export PHP_ENV_PATH


    # Add current path to the bash PATH
    PHP_ENV_OLD_VIRTUAL_PATH="$PATH"
    PATH="$PHP_ENV_PATH:$PATH"
    # Use the following if you want to make dynamic in
    # the future
    # PATH="$PATH_TO_ENV/__BIN_DIR__:$PATH" 
    export PATH

    # This should detect bash and zsh, which have a hash command that must
    # be called to get it to forget past commands.  Without forgetting
    # past commands the $PATH changes we made may not be respected
    if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
        hash -r 2>/dev/null
    fi

    # COMPOSER_HOME can be empty or not set, so we want to set a flag variable so
    # that our deactivate command can tell whether or not we originally touched
    # the Composer settings.
    export PHP_ENV_COMPOSER_GLOBAL="1"
    export PHP_ENV_OLD_COMPOSER_HOME="$COMPOSER_HOME"
    export COMPOSER_HOME="$HOME/.composer_$1"

    if [ ! -d "$COMPOSER_HOME" ] && [ ! -f "$COMPOSER_HOME" ] ; then
      mkdir "$COMPOSER_HOME"
    fi

    echo using version $PHP_EXACT_VER
    echo ''

    php -version
    echo ''

}

init_composer_dir () {
    if [ -z "$1" ]; then
        SOURCE_DIR="$HOME/.composer"
    else
        if [ $(list_php_major_versions | grep "^$1\$" ) ]; then ;
            SOURCE_DIR="$HOME/.composer_$1"
        else
            SOURCE_DIR="$1"
        fi
    fi

    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Source dir ($SOURCE_DIR) does not exits"

        return 23
    fi

    if [ -z "$COMPOSER_HOME" ] ; then
        echo "Composer home varibale is empty"

        return 42
    fi

    if [ "$COMPOSER_HOME" = "$SOURCE_DIR" ] ; then
        echo "Source and target dir are the same"

        return 2342
    fi

    COMPOSER_FILES=( "auth.json" "composer.json" "config.json" "keys.dev.pub" "keys.tags.pub" )
    for A_FILE in ${COMPOSER_FILES[@]} ; do
        if [ ! -f "$COMPOSER_HOME/$A_FILE" ] && [ -f "$SOURCE_DIR/$A_FILE" ] ; then
            cp "$SOURCE_DIR/$A_FILE" "$COMPOSER_HOME/$A_FILE" 
        fi
    done

    composer global install
    
}
