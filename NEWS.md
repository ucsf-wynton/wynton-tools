# Version 0.17.0-9000 (2025-01-28)

## New Features

 * Add support for `wynton account <user>`, which superseeds `wynton
   account --user=<user>`.

 * Add support for `wynton group <group>`, which superseeds `wynton
   group --group=<group>`.

## Bug Fixes

 * Remove stray warnings from `wynton account --check`; already using
   footnote warnings.
 

# Version 0.17.0 (2025-01-28)

## New Features

 * Add a rudimentary version of `wynton group`.

 * `wynton account --check` asserts that all GIDs exist.

 * `wynton account --check` warns when BeeGFS group quota are unlimited.

 * `wynton watchdog-ps` allows for a few more tools.
 

# Version 0.16.0 (2025-01-14)

## Significant Changes

 * `wynton --version`, `wynton --help`, etc. return exit code 0. It
   used to return exit code 1.
 
## New Features

 * `wynton account` reports on number of sponsees that the faculty
   sponsor have.

 * `wynton account` reports on number of members in the same Wynton
   project.

 * Add `wynton stray-processes`.

## Bug Fixes

 * `wynton account` would produce errors on `ldap_sasl_bind(SIMPLE):
   Can't contact LDAP server (-1)` when called from development nodes.

 * `wynton-account --check` would skip the validation of SGE certs
   that are generated prior to 2022-06-29.


# Version 0.15.0 (2025-01-13)

## New Features

 * `wynton account` reports on number of BeeGFS file chunks in HOME
   folder. With `--check` it reports on whether the HOME folder is
   disaster-recovery backed up, which depends on it being below the
   chunk threshold or not.

 * `wynton account` reports on number of group members.

 * `wynton job` reports on "Total memory requested", which is a
   function of `-l mem_free` and the number of parallel slots.

 * Now `wynton <tool> --version` is the same as `wynton --version`.

## Bug Fixes

 * `wynton account` reported on group disk quota as it is buddy
   mirrored, which it is not in most cases (yet).
 
 * `wynton account --check` required UID:s to be within
   `[1023,65535]`, whereas it should be `[1000,65535]`.


# Version 0.14.0 (2025-01-09)

## New Features

 * Add `wynton watchdog-ps --user-width=n`.

## Bug Fixes

 * `wynton watchdog-ps --hosttype=type` did not work.

 * `wynton account` would list also primary group among the secondary
   groups.

 * `wynton account --check` warnings and errors on HOME folder quota
   would report on twice the available amount, because it did not
   account for it being buddy-mirrored in BeeGFS.


# Version 0.13.0 (2025-01-06)

## New Features

 * `wynton account --check` verifies LDAP field `wyntonProject`.

 * `wynton account --check` verifies that LDAP fields
   `protectedAccess`, `wyntonAccess`, and `wyntonProject` have one and
   exactly one value.


# Version 0.12.0 (2025-01-03)

## New Features

 * `wynton account --check` verifies that user is member of the SGE
   project.
 
 * `wynton account` reports on secondary groups.

 * `wynton account` reports on storage quota for all groups.
 

# Version 0.11.0 (2024-12-23)

## New Features

 * `wynton job` now detects `-l rocky8=false` as a FAIL.

 * `wynton job` now reports on job scripts arguments (`job_args`).

 * `wynton job` now reports on more resource requests.

## Miscellaneous

 * `wynton account` now reports on the age of LDAP timestamps.
 
 * Tweaks to `wynton account` output.

## Bug Fixes

 * `wynton job` did not correctly parse requested resources.


# Version 0.10.0 (2024-12-19)

## New Features

 * `wynton account` reports also by whom the account was created and
   last modified.

 * `wynton access`: reports also on Plato access.

 * `wynton account` detects when an email address maps to more than
   one user account, which results in an error that lists the
   different usernames.
 
 * Add `wynton-watchdog-ps`.
 

# Version 0.9.0 (2024-12-13)

## New Features

 * `wynton job` reports on more job details.

 * `wynton job` how also parses `scratch` and `gpu_mem` resource
   specifications.

## Bug Fixes

 * `wynton account` would incorrectly give an error for accounts with
   `isLocked=TRUE` and `wyntonAccess=TRUE`; downgraded to a note.


# Version 0.8.0 (2024-12-02)

## New Features

 * Now `wynton account` displays account information by default. To
   also check the account, add `--check`.

 * Now `wynton account` supports also `--user=<email>`, which looks up
   the username by email address.

 * Now `wynton account` reports also on Information Commons (IC)
   access, and asserts such users have PHI access.


# Version 0.7.0 (2024-11-26)

## New Features

 * Add `wynton trash` for quickly moving large files and folders to a
   personal trash folder under `/wynton/scratch/`, which then will be
   removed by the system after two weeks.
   
 * Now `wynton account` reports also on HOME disk quota, and
   the Wynton and SGE projects.


# Version 0.6.0 (2024-11-25)

## New Features

 * Add `wynton account` for looking up account information and
   validating the account settings.
 
 * All tools taking option `--user=<username>` now also supports
   specifying user by user ID, i.e. `--user=<uid>`.

## Deprecated and Defunct

 * Deprecating option format `--key value` in favor of `--key=value`.


# Version 0.5.0 (2024-11-13)

## New Features

 * Add support for `wynton utils <utility> --apply`.
 

# Version 0.4.0 (2024-11-12)

## New Features

 * Add `wynton utils` for loading different sets of utility functions.
 
 * Add `wynton utils fuse-tmpdir` for configuring a temporary,
   size-limited TMPDIR folder, which acknowledges Wynton's local
   scratch SGE resource requests.

## Deprecated and Defunct

 * Removed `x86-64-level`, which now is a standalone tool outside of
   wynton-tools.
 

# Version 0.3.0 (2024-10-07)

## New Features

 * Add `wynton accounting`, `wynton node`, `wynton session-info`,
   and `wynton why`.

## Miscellaneous

 * Tweaks to `wynton job`.
 
## Bug Fixes

 * Fix `wynton --help` and `wynton --version` issues.
 

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
