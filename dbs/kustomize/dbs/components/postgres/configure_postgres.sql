/*
Copyright SecureKey Technologies Inc. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

CREATE USER orbvct with encrypted password 'orbvct-secret-pw';
CREATE DATABASE orbvct;
ALTER USER orbvct CREATEDB;


CREATE USER authresthydra with encrypted password 'authresthydra-secret-pw';
CREATE DATABASE authresthydra;

CREATE USER rpadapterhydra with encrypted password 'rpadapterhydra-secret-pw';
CREATE DATABASE rpadapterhydra;
