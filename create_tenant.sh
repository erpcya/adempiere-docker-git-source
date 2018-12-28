#  Copyright (C) 2003-2017, e-Evolution Consultants S.A. , http://www.e-evolution.com
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#  Email: victor.perez@e-evolution.com, http://www.e-evolution.com , http://github.com/e-Evolution

#!/usr/bin/env bash
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -z "$1" ];
then
    echo "ADempiere Application name, should use applicationFromGit.sh <Application name> up -d "
    exit 1
fi

# load environment variables

export COMPOSE_PROJECT_NAME=$1;
#Source location
export ADEMPIERE_SOURCE=/opt/Development/DockerSource/adempiere_source
#Install Dir
export ADEMPIERE_INSTALL_DIR=$ADEMPIERE_SOURCE/adempiere/install
#Tenant Dir
export TENANT_DIR=tenant
#Tenant Image Dir
export TENANT_IMAGE_DIR=$TENANT_DIR/$COMPOSE_PROJECT_NAME
#Properties
export IMAGE_PROPERTIES=$TENANT_IMAGE_DIR/properties

echo "Create Tenant Directory"
#Create Dir
mkdir $TENANT_IMAGE_DIR
mkdir $TENANT_IMAGE_DIR/lib
mkdir $TENANT_IMAGE_DIR/packages

#Get Properies
echo "Get Tenant Properties"
cp $TENANT_DIR/propertiesTemplate $IMAGE_PROPERTIES
#Validate
echo "Instance $COMPOSE_PROJECT_NAME"
. ./$IMAGE_PROPERTIES

if [ -z "$ADEMPIERE_WEB_PORT" ];
then
    echo "ADempiere HTTP port not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_SSL_PORT" ];
then
    echo "ADempiere HTTPS port not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_DB_NAME" ];
then
    echo "Initialize Database not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_BRANCH_NAME" ];
then
    echo "ADempiere Branch Name not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_VERSION" ];
then
    echo "ADempiere version not setting"
    exit 1
fi

if [ -z "$ADEMPIERE_DB_INIT" ];
then
    echo "Initialize Database not setting"
    exit 1
fi

export ADEMPIERE_WEB_PORT;
export ADEMPIERE_SSL_PORT;
export ADEMPIERE_VERSION;
export ADEMPIERE_BRANCH_NAME;
export ADEMPIERE_DB_NAME;
export ADEMPIERE_DB_INIT;
#DB Values
export ADEMPIERE_DB_HOST;
export ADEMPIERE_DB_PORT;
export ADEMPIERE_DB_USER;
export ADEMPIERE_DB_PASSWORD;
export ADEMPIERE_DB_ADMIN_PASSWORD;

echo "ADempiere Base Dir $BASE_DIR"
echo "Tenant Dir: $TENANT_IMAGE_DIR"
echo "ADempiere HTTP  port: $ADEMPIERE_WEB_PORT"
echo "ADempiere HTTPS port: $ADEMPIERE_SSL_PORT"
echo "ADempiere Version: $ADEMPIERE_VERSION"
echo "ADempiere Source: $ADEMPIERE_SOURCE"
echo "ADempiere Install Dir $ADEMPIERE_INSTALL_DIR"
echo "ADempiere Branch Name: $ADEMPIERE_BRANCH_NAME"
echo "ADempiere DB Name: $ADEMPIERE_DB_NAME"
echo "Initialize Database: $ADEMPIERE_DB_INIT"

#Get changes from github
cd $ADEMPIERE_SOURCE

echo "Git Reset"
#git reset --hard HEAD
echo "Change Branch"
#git checkout -b $ADEMPIERE_BRANCH_NAME
echo "Update Branch"
#git pull 

#Build ADempiere Project
cd $ADEMPIERE_SOURCE/utils_dev
echo "Building ADempiere source"
#sh RUN_clean.sh
#sh RUN_build.sh

cd $BASE_DIR
#Create Network
if [ "$(docker network inspect -f '{{.Name}}' custom)" != "custom" ];
then
    echo "Create custom network"
    docker network create -d bridge custom
fi

# Define Adempiere path and binary
ADEMPIERE_BINARY=Adempiere_${ADEMPIERE_VERSION//.}"LTS.tar.gz"
export ADEMPIERE_BINARY;
URL="https://github.com/adempiere/adempiere/releases/download/"$ADEMPIERE_VERSION"/"$ADEMPIERE_BINARY


#Copy ADempiere Binary
echo "Copy ADempiere binary from $ADEMPIERE_INSTALL_DIR/$ADEMPIERE_BINARY To $TENANT_IMAGE_DIR"
cp $ADEMPIERE_INSTALL_DIR/$ADEMPIERE_BINARY $TENANT_IMAGE_DIR

echo "Running docker-compoose"
    # Execute docker-compose
echo
docker-compose \
        -f "$BASE_DIR/adempiere.yml" \
        -p "$TENANT_IMAGE_DIR" \
        $2 \
        $3 \
        $4 \
        $5 
