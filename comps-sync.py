#!/usr/bin/python3
# Usage: ./comps-sync.py /path/to/comps-f29.xml.in
#
# Can both remove packages from the manifest
# which are not mentioned in comps, and add packages from
# comps.

import os, sys, subprocess, argparse, shlex, json, yaml
import libcomps

def fatal(msg):
    print >>sys.stderr, msg
    sys.exit(1)

parser = argparse.ArgumentParser()
parser.add_argument("--save", help="Write changes", action='store_true')
parser.add_argument("src", help="Source path")

args = parser.parse_args()

print("Syncing packages common to all ostree based desktop versions:")

base_pkgs_path = 'fedora-common-ostree-pkgs.json'
with open(base_pkgs_path) as f:
    manifest = json.load(f)

with open('comps-sync-blacklist.yml') as f:
    doc = yaml.safe_load(f)
    comps_blacklist = doc['blacklist']
    comps_whitelist = doc['whitelist']
    comps_blacklist_groups = doc['blacklist_groups']
    comps_desktop_blacklist = doc['desktop_blacklist']

manifest_packages = set(manifest['packages'])

comps_unknown = set()

comps_packages = set()
workstation_product_packages = set()
# Parse comps, and build up a set of all packages so we
# can find packages not listed in comps *at all*, beyond
# just the workstation environment.
comps = libcomps.Comps()
comps.fromxml_f(args.src)

# Parse the workstation-product environment, gathering
# default or mandatory packages.
ws_env_name = 'workstation-product-environment'
ws_ostree_name = 'workstation-ostree-support'
ws_environ = comps.environments[ws_env_name]
ws_pkgs = {}
for gid in ws_environ.group_ids:
    group = comps.groups_match(id=gid.name)[0]
    if gid.name in comps_blacklist_groups:
        continue
    blacklist = comps_blacklist.get(gid.name, set())
    for pkg in group.packages:
        pkgname = pkg.name
        if pkg.type not in (libcomps.PACKAGE_TYPE_DEFAULT,
                            libcomps.PACKAGE_TYPE_MANDATORY):
            continue
        if pkgname in blacklist:
            continue
        pkgdata = ws_pkgs.get(pkgname)
        if pkgdata is None:
            ws_pkgs[pkgname] = pkgdata = (pkg.type, set([gid.name]))
        if (pkgdata[0] == libcomps.PACKAGE_TYPE_DEFAULT and
            pkg.type == libcomps.PACKAGE_TYPE_MANDATORY):
            ws_pkgs[pkgname] = pkgdata = (pkg.type, pkgdata[1])
        pkgdata[1].add(gid.name)

ws_ostree_pkgs = set()
for pkg in comps.groups_match(id=ws_ostree_name)[0].packages:
    ws_ostree_pkgs.add(pkg.name)

for pkg in manifest_packages:
    if (pkg not in comps_whitelist and
        pkg not in ws_pkgs and
        pkg not in ws_ostree_pkgs):
        comps_unknown.add(pkg)

# Look for packages in the manifest but not in comps at all
n_manifest_new = len(comps_unknown)
if n_manifest_new == 0:
    print("All manifest packages are already listed in comps.")
else:
    print("{} packages not in {}:".format(n_manifest_new, ws_env_name))
    for pkg in sorted(comps_unknown):
        print('  ' + pkg)
        manifest_packages.remove(pkg)

# Look for packages in workstation but not in the manifest
ws_added = {}
for (pkg,data) in ws_pkgs.items():
    if pkg not in manifest_packages:
        ws_added[pkg] = data
        manifest_packages.add(pkg)

def format_pkgtype(n):
    if n == libcomps.PACKAGE_TYPE_DEFAULT:
        return 'default'
    elif n == libcomps.PACKAGE_TYPE_MANDATORY:
        return 'mandatory'
    else:
        assert False

n_comps_new = len(ws_added)
if n_comps_new == 0:
    print("All comps packages are already listed in manifest.")
else:
    print("{} packages not in manifest:".format(n_comps_new))
    for pkg in sorted(ws_added):
        (req, groups) = ws_added[pkg]
        print('  {} ({}, groups: {})'.format(pkg, format_pkgtype(req), ', '.join(groups)))

if (n_manifest_new > 0 or n_comps_new > 0) and args.save:
    manifest['packages'] = sorted(manifest_packages)
    with open(base_pkgs_path, 'w') as f:
        json.dump(manifest, f, indent=4, sort_keys=True)
        f.write('\n')
        print("Wrote {}".format(base_pkgs_path))


# Generate treefiles for all desktops
for desktop in [ 'gnome-desktop', 'kde-desktop', 'xfce-desktop', 'lxqt-desktop' ]:
    print()
    print("Syncing packages for {} specific version:".format(desktop))

    base_pkgs_path = '{}-pkgs.json'.format(desktop)
    with open(base_pkgs_path) as f:
        manifest = json.load(f)

    manifest_packages = set(manifest['packages'])
    ws_ostree_name = desktop

    comps_unknown = set()
    comps_packages = set()
    workstation_product_packages = set()

    # Parse the desktop group
    ws_pkgs = set()
    for pkg in comps.groups_match(id=desktop)[0].packages:
        pkgname = pkg.name
        blacklist = comps_desktop_blacklist.get(ws_ostree_name, set())
        if pkgname in blacklist:
            continue
        ws_pkgs.add(pkg.name)

    for pkg in manifest_packages:
        if pkg not in ws_pkgs:
            comps_unknown.add(pkg)

    # Look for packages in the manifest but not in comps at all
    n_manifest_new = len(comps_unknown)
    if n_manifest_new == 0:
        print("All manifest packages are already listed in comps.")
    else:
        print("{} packages not in {}:".format(n_manifest_new, ws_ostree_name))
        for pkg in sorted(comps_unknown):
            print('  ' + pkg)
            manifest_packages.remove(pkg)

    # Look for packages in comps but not in the manifest
    ws_added = set()
    for pkg in ws_pkgs:
        if pkg not in manifest_packages:
            ws_added.add(pkg)
            manifest_packages.add(pkg)

    n_comps_new = len(ws_added)
    if n_comps_new == 0:
        print("All comps packages are already listed in manifest.")
    else:
        print("{} packages not in manifest:".format(n_comps_new))
        for pkg in sorted(ws_added):
            print('  {}'.format(pkg))

    if (n_manifest_new > 0 or n_comps_new > 0) and args.save:
        manifest['packages'] = sorted(manifest_packages)
        with open(base_pkgs_path, 'w') as f:
            json.dump(manifest, f, indent=4, sort_keys=True)
            f.write('\n')
            print("Wrote {}".format(base_pkgs_path))
