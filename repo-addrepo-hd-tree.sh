#
# Copyright (C) 2022  Red Hat, Inc.
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
#

# FIXME: Fails on RHEL 8: "Nothing useful found for Hard drive ISO source"
# Ignore unused variable parsed out by tooling scripts as test tags metadata
# shellcheck disable=SC2034
TESTTYPE="packaging repo harddrive skip-on-rhel-8 gh790"

. ${KSTESTDIR}/functions.sh

prepare_disks() {
    local tmp_dir="${1}"
    qemu-img create -q -f qcow2 ${tmpdir}/disk-a.img 10G
    qemu-img create -q -f qcow2 ${tmpdir}/disk-b.img 12G
    echo ${tmpdir}/disk-a.img ${tmpdir}/disk-b.img
}

prepare() {
    local ks="$1"
    local tmp_dir="$2"
    local httpd_url=""

    # Create an empty repository.
    mkdir -p "${tmp_dir}/http/repo"
    createrepo_c -q "${tmp_dir}/http/repo"

    # Start a http server to serve the repository.
    start_httpd "${tmp_dir}/http" "${tmp_dir}"

    # Substitute variables in the kickstart file.
    sed -e "s|EMPTY_REPO_URL|${httpd_url}/repo|" "${ks}" > "${tmp_dir}/ks.cfg"
    echo "${tmp_dir}/ks.cfg"
}

kernel_args() {
    echo "${DEFAULT_BOOTOPTS} inst.addrepo=addon,hd:/dev/vdb:/repo"
}

cleanup() {
    local tmp_dir="${1}"
    stop_httpd "${tmp_dir}"
}
