- add storages: Hadoop DFS, MongoDB, Amazon S3
- remove :host from Vfs to Vos
- efficient version of :copy for files and dirs (there's a problem thought, FileUtils.cp_r overrides files silntly, don't know how to do it)?
- efficient (not copy/destroy) versions of move_to, rename
- handy :chmod helpers (via attributes)
- add storages: remote FS over HTTP?

# Done:

- refactor specs with :fakefs (rejected, there are bugs in fakefs)
- glob search for directories: Dir['**/*.yml']
- Vos: Dir.bash
- File.append
- list of entries/files/dirs
- support for efficient copy for Local and SSH storages