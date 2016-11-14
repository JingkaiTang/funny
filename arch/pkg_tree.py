#!/usr/bin/env python

import os
import sys

KW_DEPENDS_ON = 'Depends On'


def get_pkg_info(pkg):
    return os.popen('pacman -Si %s' % pkg)


def get_dep_pkgs(pkg):
    pkg_info = get_pkg_info(pkg)
    deps = filter(lambda l: l.startswith(KW_DEPENDS_ON), pkg_info)
    deps = ''.join(deps)
    try:
        dep_pkgs = deps[deps.index(':')+1:]
    except ValueError:
        return None
    dep_pkgs = dep_pkgs.strip().split(' ')
    return list(filter(lambda p: p, dep_pkgs))


def get_dep_tree(pkg):
    dep_pkgs = [pkg]
    err_pkgs = []
    i = 0
    while i != len(dep_pkgs):
        pkg = dep_pkgs[i]
        dps = get_dep_pkgs(pkg)
        if dps:
            for p in dps:
                if p not in dep_pkgs and p not in err_pkgs:
                    dep_pkgs.append(p)
            i += 1
        else:
            err_pkgs.append(pkg)
            dep_pkgs.remove(pkg)
    return dep_pkgs[1:], err_pkgs

if __name__ == '__main__':
    if len(sys.argv) == 2:
        dp, ep = get_dep_tree(sys.argv[1])
        print('Denpends on:')
        print(dp)
        print(ep)
    else:
        print('usage: %s pkg' % sys.argv[0])
