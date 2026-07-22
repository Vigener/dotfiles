# Troubleshooting Log: Karabiner-Elements App Launch Failure

## Problem Description
After running the following command to add Bun to the user path and restarting the Mac, Karabiner-Elements was unable to launch or focus apps (e.g., `Dia` browser via [Kana + N] or [Kana + G]) when they were inactive.
However, hiding active apps (Cmd+H) still worked.

```zsh
sudo launchctl config user path "$(launchctl getenv PATH):/Users/mikoto/.bun/bin"
```

## Root Cause Analysis
1. **Empty Output of `launchctl getenv PATH`**: By default, `launchctl getenv PATH` returns an empty string unless a custom path has been explicitly set.
2. **PATH Corruption**: Substituting the empty output into the command resulted in setting the system user path to `:/Users/mikoto/.bun/bin`.
3. **Loss of System Paths**: This setting completely removed critical system paths (like `/usr/bin`, `/bin`, `/usr/sbin`, `/sbin`) from the launchd environment.
4. **Command Execution Failure in Karabiner**:
   - Karabiner-Elements' app launch functionality (such as `toApp()`) and shell commands (such as `open -b` or `osascript` in custom toggle functions) rely on system binaries located in `/usr/bin/open` or `/usr/bin/osascript`.
   - Since these paths were missing from the environment `PATH`, Karabiner could not locate or execute these binaries, causing app launching to fail.
   - Hiding an active app (Cmd+H) uses direct keyboard event emulation (sending `Command + H`), which does not rely on external system commands, so it continued to function.

---

## Analysis of Solutions for Zed / GUI App PATH issues

The user's goal was to make the `pi` command (installed via `bun`) recognizable by GUI applications like Zed, which do not load `.zshrc`.

### Risks of Modifying `launchctl config user path` (Option 2)
1. **Global Environment Pollution**: Changing the environment path for all user processes affects every GUI application and background agent. This can cause unexpected side effects (e.g., conflicting node/python versions).
2. **Hard to Debug**: These settings are hidden in `/private/var/db` plists rather than shell configuration files (`.zshrc` etc.), making future debugging difficult.
3. **Poor Maintainability**: Any change requires a macOS reboot to take effect.

### Evaluation of Package Managers (npm vs Bun)
- **Startup Speed**: The startup speed difference for a CLI tool like `pi` between npm and bun is negligible.
- **Path Resolution**: Globally installing via `npm` (usually under Homebrew's `/opt/homebrew/bin` or `/usr/local/bin`) makes it more likely to be found automatically by GUI applications, because many GUI apps hardcode these standard search paths. However, it still doesn't guarantee resolution if the app restricts its PATH.

### Recommended Alternatives

#### 1. Move PATH exports to `~/.zprofile` (Highly Recommended)
GUI apps like Zed and VS Code usually spawn a *login shell* in the background to import environment variables.
- Intersecting configuration files: `.zshrc` is only loaded for *interactive* shells (like Terminal), whereas `.zprofile` is loaded for *login* shells (which GUI apps trigger).
- **Action**: Move the Bun path export from `~/.zshrc` to `~/.zprofile`:
  ```zsh
  export PATH="$HOME/.bun/bin:$PATH"
  ```

#### 2. Configure Absolute Paths inside the GUI Application
If `pi` is called via Zed tasks or keymaps, reference it using its absolute path:
`/Users/mikoto/.bun/bin/pi` (or dynamic `$HOME/.bun/bin/pi`). This keeps the system environment completely clean.

#### 3. Use `/etc/paths.d/` for macOS standard path extension
If system-wide path extension is truly necessary, macOS provides `/etc/paths.d/` as a cleaner, standard way:
- Create a file `/etc/paths.d/bun` containing `/Users/mikoto/.bun/bin`.
- This avoids plist hacks and is parsed naturally by the system.

---

## 🛠️ Actual Action Taken (2026-07-19)

The following steps were successfully executed to resolve the issue:
1. **Cleaned up the broken `launchctl` configuration**:
   Deleted the custom `PathEnvironmentVariable` from the user-level launchd configuration:
   ```zsh
   sudo defaults delete /private/var/db/com.apple.xpc.launchd/config/user PathEnvironmentVariable
   ```
2. **Created and managed `~/.zprofile`**:
   - Placed the Bun path configuration (`export PATH="$HOME/.bun/bin:$PATH"`) along with Homebrew and OrbStack initialization inside `~/.zprofile`.
   - Moved this file to the dotfiles directory at `~/dotfiles/zsh/.zprofile` for future maintainability.
3. **Re-stowed the Zsh configuration**:
   - Removed the conflicting `dotfiles/zsh/.DS_Store`.
   - Ran `stow -R zsh` to establish proper symlinks:
     - `~/.zprofile -> dotfiles/zsh/.zprofile`
     - `~/.zshrc -> dotfiles/zsh/.zshrc`
4. **Result**:
   - Karabiner-Elements recovered its ability to focus and launch applications (like `Dia`).
   - Zed and other GUI applications can now successfully resolve the `pi` command via the login-shell path mechanism without system-wide environment pollution.

