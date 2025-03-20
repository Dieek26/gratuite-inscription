#!/bin/sh

source_folder="/usr/local/share/public"
lock_folder="init.lock"

initialize() {
	if mkdir "$source_folder/$lock_folder"; then
		echo "Locking succeeded" >&2
	else
		echo "Lock failed" >&2

		return
	fi

	trap "[ -d \"$source_folder/$lock_folder\" ] && rmdir \"$source_folder/$lock_folder\"" EXIT

    rsync -a "$source_folder/" --exclude="*.lock" /var/www/app/public

	rmdir "$source_folder/$lock_folder"
}

setuser() {
	uid=${DEV_USER_ID:-33}
	gid=${DEV_GROUP_ID:-33}

	usermod -u $uid www-data
	groupmod -g $gid www-data
}

setpermissions() {
	chown --recursive www-data: /var/www/app/var/cache /var/www/app/var/log
	chmod -Rf 775 /var/www/app/var/cache /var/www/app/var/log
}

setuser
initialize
setpermissions

exec "$@"
