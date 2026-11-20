# Project 5: Secure Linux Server Permissions

## Goal
Apply **user-based access restrictions** on a Linux server using users, groups and
file-system permissions, then **prove** that authorized users are allowed and
unauthorized users are denied.

## Environment
| Item | Value |
|---|---|
| OS | Ubuntu 24.04.3 LTS |
| Host | Cloud VM (Azure) |
| Admin account | `clouduser` (sudo) |

## Design

### Users and groups
| User | Group (team) | Role |
|---|---|---|
| alice | devteam | Developer |
| bob | devteam | Developer |
| charlie | opsteam | Operations |

### Folders and permissions
| Folder | Owner:Group | Mode | Owner | Group | Others |
|---|---|---|---|---|---|
| `/srv/project5/dev` | root:devteam | `2770` | rwx | rwx | --- (no access) |
| `/srv/project5/ops` | root:opsteam | `2770` | rwx | rwx | --- (no access) |
| `/srv/project5/shared` | root:opsteam | `2775` | rwx | rwx | r-x (read-only) |

**Permission values:** r (read) = 4, w (write) = 2, x (enter folder / execute file) = 1.
The leading `2` is the **setgid** bit: new files inside the folder automatically
belong to the folder's team group, so teammates can share files.

## Implementation steps
1. Verified admin access with `sudo whoami`.
2. Created groups with `groupadd devteam` and `groupadd opsteam`.
3. Created users with `useradd -m -s /bin/bash -G <group> <user>`.
4. Created team folders under `/srv/project5`.
5. Assigned ownership with `chown root:<group> <folder>`.
6. Applied permissions with `chmod 2770` (private team folders) and `chmod 2775` (shared folder).
7. Tested access as each user with `sudo -u <user> <command>`.

## How to run
~~~bash
sudo ./setup.sh        # create users, groups, folders and permissions (safe to re-run)
sudo ./test_access.sh  # run all allowed/denied tests and print PASS/FAIL
sudo ./cleanup.sh      # remove everything created by this project (asks for confirmation)
~~~

## Test results (16 / 16 passed)

### Allowed access
| User | Action | Result |
|---|---|---|
| alice (devteam) | List / create files in `dev` | Allowed |
| bob (devteam) | Read alice's file in `dev` | Allowed |
| charlie (opsteam) | Create files in `ops` and `shared` | Allowed |
| alice, bob | List / read files in `shared` | Allowed (read-only) |

### Denied access
| User | Action | Result |
|---|---|---|
| alice (devteam) | List or create files in `ops` | Permission denied |
| charlie (opsteam) | List `dev` or read dev files | Permission denied |
| alice | Create or modify files in `shared` | Permission denied |
| bob | Delete a file in `shared` | Permission denied |
| nobody (outsider) | List `dev` or `ops` | Permission denied |
| clouduser (no team, no sudo) | List `dev` | Permission denied |

## Screenshots
| # | Description | Image |
|---|---|---|
| P5-01 | sudo access confirmed | ![P5-01](screenshots/P5-01_sudo_check.png) |
| P5-02 | Groups created | ![P5-02](screenshots/P5-02_groups_created.png) |
| P5-03 | Users and group membership | ![P5-03](screenshots/P5-03_users_and_membership.png) |
| P5-04 | Folder ownership and permissions | ![P5-04](screenshots/P5-04_folder_permissions.png) |
| P5-05 | Allowed access tests | ![P5-05](screenshots/P5-05_allowed_access.png) |
| P5-06 | Denied access tests | ![P5-06](screenshots/P5-06_denied_access.png) |
| P5-07 | Shared folder (read-only) tests | ![P5-07](screenshots/P5-07_shared_folder.png) |
| P5-08 | Automated test report (16/16 PASS) | ![P5-08](screenshots/P5-08_automated_tests.png) |

## Key learnings and security observations
- **Least privilege:** each user gets only the access their role needs.
- **Group-based access scales:** to grant access to a new developer, just add them to `devteam`.
- **Folder `x` controls entry:** without it, a user cannot reach files inside, even if they know the exact file name.
- **Deleting a file depends on the folder's `w` permission**, not the file's.
- **setgid on team folders** keeps new files owned by the team group.
- **Test users have no password**, so they cannot log in directly; testing was done with `sudo -u`.
- **Automated, repeatable tests** (`test_access.sh`) make it easy to re-verify after any change, such as a VM restart.

## Repository structure
~~~
project5-linux-permissions/
|-- README.md          # This write-up
|-- setup.sh           # Creates users, groups, folders and permissions
|-- test_access.sh     # Automated allowed/denied access tests
|-- cleanup.sh         # Removes everything created by setup.sh
|-- .gitignore         # Files Git must never upload
`-- screenshots/       # Evidence screenshots (P5-01 to P5-08)
~~~
