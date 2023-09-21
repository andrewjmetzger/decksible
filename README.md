# Decksible

*Ansible for your Steam Deck*

> **Warning**
Requires an SD card. Temporarily enables/uses sudo.
 
# Quick Start

```sh
curl -sSL https://wget.lol/decksible | sh
```

# Tasks and Features

  - Fully automatic Steam Deck setup with Ansible. Run 'n' done!
  - Not affected by updates/resets -- keeps your Deck's system partition read-only.
  - Temporarily sets the sudo password to `deck` for tasks requiring elevation.
  - Installs
    - [Common Flatpack apps](install-flatpaks.yml#L10)
    - [Decky Loader](https://decky.xyz/)
    - [EmuDeck](https://www.emudeck.com/)
