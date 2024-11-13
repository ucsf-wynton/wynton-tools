# Version (development version)

## New Features

 * Add `wynton utils` for loading different sets of utility functions.
 
 * Add `wynton utils fuse-tmpdir` for configuring a temporary,
   size-limited TMPDIR folder, which acknowledges Wynton's local
   scratch SGE resource requests.

## Deprecated and Defunct

 * Removed `x86-64-level`, which now is a standalone tool outside of
   wynton-tools.
 

# Version 0.2.0 (2022-12-14)

## New Features

 * Add `x86-64-level` to get the x86-64 microarchitecture level that
   the CPU on the current machine support, i.e. x86-64-v1, x86-64-v2,
   x86-64-v3, or x86-64-v4.
 

# Version 0.1.0 (2022-12-06)

## New Features

 * `wynton-gpushares` now outputs a 'queue' column too.
 
 * `wynton-gpushares` gained argument `--queue=<pattern>`.


# Version 0.0.13 (2022-12-06)

## New Features

 * Add `fzf_qview`.

## Bug Fixes

 * `wynton-gpushares` would not filter on the (internal) `queue`
   variable.
   

# Version 0.0.12 (2022-05-05)

## Bug Fixes

 * `wynton-shares --fshares` would produce invalid output if `qconf`
   produces replicated entries. Now the parser looks at only unique
   entries.


# Version 0.0.11 (2022-01-19)

## New Features

 * Add `trash` for quickly moving a file or a folder to a central
   trash folder on the global scratch, where it will eventually be
   cleaned out by the garbage collector that wipes anything older than
   two weeks.

 * Add `qview` for getting a summary of an active job. Add `fzf_qview`
   for using `qview` with multiple jobs via fuzzy search.
 
 
# Version 0.0.10 (2021-08-02)

## New Features

 * Add `wynton gpushares` for reporting on GPU shares.


# Version 0.0.9 (2020-10-04)

## New Features

 * Add `wynton bench` for reporting on disk I/O benchmarks.


# Version 0.0.8 (2019-09-11)

## New Features

 * Now `wynton shares tsv` is sorted by first column.
 

# Version 0.0.7 (2019-07-23)

## New Features

 * Now `wynton status` reports also on the job scheduler version.
 
 * Now `wynton quota` reports also on group storage.
 
 * Now `wynton quota` gives an informative error if user does not found.

## Bug Fixes

 * `wynton quota --user <custom>` would output invalid uid and gid.


# Version 0.0.6 (2019-07-01)

## New Features

 * Now `wynton status` reports on the versions of the operating system and the
   BeeGFS file system.
   

# Version 0.0.5 (2019-04-20)

## New Features

 * Add support for `wynton queues list --funits`.


# Version 0.0.4 (2019-04-01)

## New Features

 * Add `wynton queues list`.


# Version 0.0.3 (2019-03-28)

## New Features

 * Add `wynton status load`.


# Version 0.0.2 (2019-03-25)

## New Features

 * Add `wynton quota`.


# Version 0.0.1 (2019-03-21)

## New Features

 * Add `wynton` master tool.
 
 * Add `wynton shares` to list member.q shares.
 
 * Created.
