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
## @fn download-jdbc-auth.sh
##
## Downloads JDBC authentication support, including any required JDBC drivers.
## The downloaded files will be grouped by their associated database type, with
## all MySQL files being placed within the "mysql/" subdirectory of the
## destination, and all PostgreSQL files being placed within the "postgresql/"
## subdirectory of the destination.
##
## @param VERSION
##     The version of guacamole-auth-jdbc to download, such as "0.9.6".
##
## @param DESTINATION
##     The directory to save downloaded files within. Note that this script
##     will create database-specific subdirectories within this directory,
##     and downloaded files will be thus grouped by their respected database
##     types.
##

VERSION="$1"
DESTINATION="$2"

#
# Create destination, if it does not yet exist
#

mkdir -p "$DESTINATION"

#
# Download Guacamole JDBC auth
#

echo "Downloading auth-user-files auth version $VERSION ..."
curl -L "https://github.com/GreenRover/guacamole-auth-userfiles/releases/download/$VERSION/guacamole-auth-userfiles-$VERSION.jar"
