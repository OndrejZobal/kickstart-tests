#
# Copyright (C) 2016  Red Hat, Inc.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of
# the GNU General Public License v.2, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY expressed or implied, including the implied warranties of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.  You should have received a copy of the
# GNU General Public License along with this program; if not, write to the
# Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.  Any Red Hat trademarks that are incorporated in the
# source code or documentation are not subject to the GNU General Public
# License and may only be used or replicated with the express permission of
# Red Hat, Inc.

TESTTYPE="storage"

. ${KSTESTDIR}/functions.sh

prepare_disks() {
    tmpdir=$1

    # Need an extra two disks for RAID, but they don't need to be big
    qemu-img create -q -f qcow2 ${tmpdir}/disk-a.img 10G
    qemu-img create -q -f qcow2 ${tmpdir}/disk-b.img 1G
    qemu-img create -q -f qcow2 ${tmpdir}/disk-c.img 1G
    echo ${tmpdir}/disk-a.img ${tmpdir}/disk-b.img ${tmpdir}/disk-c.img
}

validate() {
    disksdir=$1
    # The raid disks don't contain anything relevant to the results, so leave
    # those out
    args="-a ${disksdir}/disk-a.img"

    # There should be a /root/RESULT file with results in it.  Check
    # its contents and decide whether the test finally succeeded or
    # not.
    result=$(virt-cat ${args} -m /dev/disk/by-label/rootfs /root/RESULT)
    if [[ $? != 0 ]]; then
        status=1
        echo '*** /root/RESULT does not exist in VM image.'
    elif [[ "${result}" != SUCCESS* ]]; then
        status=1
        echo "${result}"
    fi

    return ${status}
}
