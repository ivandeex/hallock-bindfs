#!/usr/bin/env ruby
#
#   Copyright 2006,2007,2008 Martin Pärtel <martin.partel@gmail.com>
#
#   This file is part of bindfs.
#
#   bindfs is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 2 of the License, or
#   (at your option) any later version.
#
#   bindfs is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with bindfs.  If not, see <http://www.gnu.org/licenses/>.
#

require 'common.rb'

# Treat parameters as test names and run only those
$only_these_tests = ARGV unless ARGV.empty?

# Some useful shorthands
nobody_uid = Etc.getpwnam('nobody').uid
nogroup_gid = Etc.getgrnam('nogroup').gid


# Let's start by checking that mounting works at all
testenv('mounting', "") do
    assert { File.basename(pwd) == TESTDIR_NAME }
end

# Setting the owner of files to nobody/nogroup
testenv('set_owner', "-u nobody -g nogroup") do
    touch('src/file')

    assert { File.stat('mnt/file').uid == nobody_uid }
    assert { File.stat('mnt/file').gid == nogroup_gid }
end

# Setting permission bits
testenv('permbits', "-p 0600:u+D") do
    touch('src/file')
    chmod(0777, 'src/file')

    assert { File.stat('mnt/file').mode & 0777 == 0600 }
end

# Setting the file owner
testenv('simple_pattern', "-u nobody") do
    touch('src/file')

    assert { File.stat('mnt/file').uid == nobody_uid }
end

# Test setting chmod policy
testenv('chmod_policy', "--chmod-deny") do
    touch('src/file')

    assert_exception(Errno::EPERM) { chmod(0777, 'mnt/file') }
end

# Test --mirror
testenv('mirror', "-u nobody -m #{Process.uid} -p 0600,u+D") do
    touch('src/file')

    assert { File.stat('mnt/file').uid == Process.uid }
end

# Test --create-with-perms
testenv('create_with_perms', "--create-with-perms=og=r:ogd+x") do
    touch('src/file')
    mkdir('src/dir')

    assert { File.stat('mnt/file').mode & 0077 == 0044 }
    assert { File.stat('mnt/dir').mode & 0077 == 0055 }
end

# Test --ctime-from-mtime
testenv('ctime-from-mtime', "--ctime-from-mtime") do
    sf = 'src/file'
    mf = 'mnt/file'
    
    touch(sf)
    sleep(1.1)
    chmod(0777, mf)
    
    assert { File.stat(mf).ctime == File.stat(mf).mtime }
    assert { File.stat(sf).ctime > File.stat(sf).mtime }
    
end

# Test --chmod-allow-x with --chmod-ignore
testenv('chmod-allow-x_with_chmod-ignore', "--chmod-allow-x --chmod-ignore") do 
    touch('src/file')

    chmod(01700, 'src/file') # sticky bit set

    chmod(00077, 'mnt/file') # should change x bits; should not unset sticky bit
    assert { File.stat('src/file').mode & 07777 == 01611 }


    mkdir('src/dir')
    chmod(0700, 'src/dir')
    chmod(0077, 'mnt/dir') # bits on dir should not change
    assert { File.stat('src/dir').mode & 0777 == 0700 }
end

# Test --chmod-allow-x with --chmod-deny
testenv('chmod-allow-x_with_chmod-deny', "--chmod-deny --chmod-allow-x") do 
    touch('src/file')

    chmod(0700, 'src/file')

    chmod(0700, 'mnt/file') # no-op chmod should work

    assert_exception(Errno::EPERM) { chmod(0777, 'mnt/file') }
    assert_exception(Errno::EPERM) { chmod(0000, 'mnt/file') }
    assert_exception(Errno::EPERM) { chmod(01700, 'mnt/file') } # sticky bit

    chmod(0611, 'mnt/file') # chmod that only changes x-bits should work
    assert { File.stat('src/file').mode & 07777 == 00611 }


    mkdir('src/dir')
    chmod(0700, 'src/dir')
    assert_exception(Errno::EPERM) { chmod(0700, 'mnt/dir') } # chmod on dir should not work
end

