#!/bin/sh -e
#
# Copyright (C) 2015 Glyptodon LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

##
## @fn start.sh
##
## Automatically configures and starts Guacamole under Tomcat. Guacamole's
## guacamole.properties file will be automatically generated based on the
## linked database container (either MySQL or PostgreSQL) and the linked guacd
## container. The Tomcat process will ultimately replace the process of this
## script, running in the foreground until terminated.
##

GUACAMOLE_HOME="$HOME/.guacamole"
GUACAMOLE_EXT="$GUACAMOLE_HOME/extensions"
GUACAMOLE_LIB="$GUACAMOLE_HOME/lib"
GUACAMOLE_PROPERTIES="$GUACAMOLE_HOME/guacamole.properties"

##
## Sets the given property to the given value within guacamole.properties,
## creating guacamole.properties first if necessary.
##
## @param NAME
##     The name of the property to set.
##
## @param VALUE
##     The value to set the property to.
##
set_property() {

    NAME="$1"
    VALUE="$2"

    # Ensure guacamole.properties exists
    if [ ! -e "$GUACAMOLE_PROPERTIES" ]; then
        mkdir -p "$GUACAMOLE_HOME"
        echo "# guacamole.properties - generated `date`" > "$GUACAMOLE_PROPERTIES"
    fi

    # Set property
    echo "$NAME: $VALUE" >> "$GUACAMOLE_PROPERTIES"

}

##
## Sets the given property to the given value within guacamole.properties only
## if a value is provided, creating guacamole.properties first if necessary.
##
## @param NAME
##     The name of the property to set.
##
## @param VALUE
##     The value to set the property to, if any. If omitted or empty, the
##     property will not be set.
##
set_optional_property() {

    NAME="$1"
    VALUE="$2"

    # Set the property only if a value is provided
    if [ -n "$VALUE" ]; then
        set_property "$NAME" "$VALUE"
    fi

}

##
## Adds properties to guacamole.properties which select the MySQL
## authentication provider, and configure it to connect to the linked MySQL
## container. If a MySQL database is explicitly specified using the
## MYSQL_HOSTNAME and MYSQL_PORT environment variables, that will be used
## instead of a linked container.
##
associate_authfilesl() {


    # Update config file
    set_property "auth-provider" "net.sourceforge.guacamole.net.auth.userfiles.UserFilesAuthenticationProvider"


    # Add required .jar files to GUACAMOLE_LIB and GUACAMOLE_EXT
    ln -s /opt/guacamole/guacamole-auth-userfiles-*.jar "$GUACAMOLE_EXT"

}

##
## Starts Guacamole under Tomcat, replacing the current process with the
## Tomcat process. As the current process will be replaced, this MUST be the
## last function run within the script.
##
start_guacamole() {
    cd /usr/local/tomcat
    exec catalina.sh run
}

#
# Start with a fresh GUACAMOLE_HOME
#

rm -Rf "$GUACAMOLE_HOME"

#
# Create and define Guacamole lib and extensions directories
#

mkdir -p "$GUACAMOLE_EXT"
mkdir -p "$GUACAMOLE_LIB"

#
# Point to associated guacd
#

# Verify required link is present
if [ -z "$GUACD_PORT_4822_TCP_ADDR" -o -z "$GUACD_PORT_4822_TCP_PORT" ]; then
    cat <<END
FATAL: Missing "guacd" link.
-------------------------------------------------------------------------------
Every Guacamole instance needs a corresponding copy of guacd running. Link a
container to the link named "guacd" to provide this.
END
    exit 1;
fi

# Update config file
set_property "guacd-hostname" "$GUACD_PORT_4822_TCP_ADDR"
set_property "guacd-port"     "$GUACD_PORT_4822_TCP_PORT"

#
# Track which authentication backends are installed
#

INSTALLED_AUTH="userfiles"

#put some files in place
echo "    <user-mapping>

        <!-- This needs to be empty. -->

    </user-mapping>"  > $GUACAMOLE_HOME/user-mapping.xml
echo "    <configs>

    </configs>" > $GUACAMOLE_HOME/noauth-config.xml

#
# Finally start Guacamole (under Tomcat)
#

start_guacamole

