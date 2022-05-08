#! /bin/bash

# Source: https://stackoverflow.com/a/24597941
function fail {
    printf '%s\n' "$1" >&2  # Send message to stderr.
    exit "${2-1}"  # Return a code specified by $2 or 1 by default.
}


# This script's directory.
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Read config file.
. "${dir}/.config"

# Required commands.
commands=("qemu-system-x86_64 ssh")
for c in "${commands[@]}"
do
if ! command -v "${c}" &> /dev/null
then
    fail "${c} could not be found"
fi
done

cd "${dir}/../images" || fail "could not cd to /images dir"

qemu-system-x86_64 -curses -enable-kvm -drive file=minix.img -rtc base=localtime -net user,hostfwd=tcp::"${ssh_port}"-:22 -net nic,model=virtio -m 1024M

echo "setting the timezone"
current_time=$(date "+%C%y%m%d%H%M.%S")
ssh root@localhost -p "${ssh_port}" "echo export TZ=Europe/Warsaw > /etc/rc.timezone"
ssh root@localhost -p "${ssh_port}" "date ${current_time}"
