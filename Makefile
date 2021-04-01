#
# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0

.PHONY: all checks license

all: checks

checks: license

license:
	@scripts/check_license.sh
