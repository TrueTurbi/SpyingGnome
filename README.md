# SpyingGnome

A fully configurable consumable checker for your raids.

## What Does SpyingGnome Do?

SpyingGnome automatically checks every member of your raid group to see if they have the consumables you've configured. It can check for:

- **Flasks** - Multi-hour consumables (like Flask of the Titans, Flask of Supreme Power, etc.)
- **Battle Elixirs** - Elixirs tagged with "Battle Elixir" (like Elixir of the Mongoose, Elixir of Giants, etc.)
- **Guardian Elixirs** - Elixirs tagged with "Guardian Elixir" (like Elixir of Superior Defense, Elixir of Fortitude, etc.)
- **Food Buffs** - Any food that provides a "Well Fed" or other food-related buff
- **Protection Potions** - Resistance potions for specific damage types (Fire, Frost, Arcane, Nature, Shadow, Holy)

The addon will tell you exactly which players are missing which at least one from these consumable categories (Depending on your configuration), making it easy to ensure your raid is properly prepared.

## Getting Started

### Opening the Addon

Type either of these commands in chat to open the SpyingGnome configuration window:

- `/sg`
- `/spyinggnome`

You'll see the main configuration window with all the options:

![Main Configuration Window](https://github.com/user-attachments/assets/0cc6ded5-87d9-42a7-9e30-f0ce7be02709)

### Basic Setup

1. **Enable SpyingGnome** - Make sure this checkbox is checked (it's the master switch for the entire addon)
2. **Choose What to Check** - Select which consumables you want to monitor:
   - Check for missing Flasks
   - Check for missing Battle Elixirs
   - Check for missing Guardian Elixirs
   - Check for missing Food buff
   - Check for missing Protection buffs

3. **Configure Specific Items** - Click the red "Configuration" button at the top to choose exactly which flasks, elixirs, and protections to check for

4. **Perform a Check** - Click the "Perform check" button at the bottom to manually check your raid

## How It Works

### Manual Checks

When you click the "Perform check" button, SpyingGnome will:

1. Check every player in your raid group
2. Look at all their active buffs
3. Compare them against your configured consumables
4. Report any missing items

**Important:** The addon only works when you're in a raid group. If you try to use it while not in a raid, you'll see a message telling you that you need to be in a raid party.

### Automatic Checks After Ready Check

If you enable "Print to raid chat after a ready check", SpyingGnome will automatically check your raid whenever a ready check completes. This is perfect for quickly verifying everyone is prepared right before a pull!

### Where You'll See Messages

SpyingGnome can show you results in two places:

1. **Your Chat Window** - You'll always see messages in your personal chat (unless you've disabled SpyingGnome entirely). These messages show you who's missing what, with player names in color.

2. **Raid Chat** - If you're a Raid Leader or Raid Officer and have "Enable Status Report Printing in Raid Chat" checked, the addon will INSTEAD announce missing consumables to the entire raid.

**Note:** Only Raid Leaders and Officers can send messages to raid chat. If you're a regular raider, you'll only see messages in your personal chat window.

## Configuration Guide

### Main Configuration Window

The main window (`/sg`) has several important options:

- **Enable SpyingGnome** - Master switch. If unchecked, the addon won't do anything.
- **Enable Status Report Printing in Raid Chat** - Allows the addon to send messages to raid chat (Raid Leaders/Officers only)
- **Print to raid chat after a ready check** - Automatically checks and reports after ready checks complete
- **Check for missing Flasks** - Enable checking for flasks
- **Check for missing Battle Elixirs** - Enable checking for battle elixirs
- **Check for missing Guardian Elixirs** - Enable checking for guardian elixirs
- **Check for missing Food buff** - Enable checking for food buffs
- **Check for missing Protection buffs** - Enable checking for protection potions

### Detailed Configuration

Click the red "Configuration" button to open the detailed consumable selection window:

![Buff Configuration Window](https://github.com/user-attachments/assets/f129e641-1eee-462b-bf9b-57e22844aa0e)

Here you can:

- **Select Specific Flasks** - Choose which flasks to check for (Flask of the Titans, Flask of Supreme Power, etc.)
- **Select Battle Elixirs** - Choose which battle elixirs to check for (Elixir of the Mongoose, Elixir of Giants, etc.)
- **Select Guardian Elixirs** - Choose which guardian elixirs to check for (Elixir of Superior Defense, Elixir of Fortitude, etc.)
- **Select Protection Types** - Choose which protection potions to check for (Fire Protection, Frost Protection, etc.)

Each consumable shows its stat bonuses in colored text. You can hover over protection potions to see detailed item information in a tooltip.

**Important:** The addon only checks for consumables that are both:
1. Enabled in the main window (e.g., "Check for missing Flasks" is checked)
2. Selected in the Configuration window (e.g., "Flask of the Titans" is checked)

If you enable "Check for missing Flasks" but don't select any specific flasks in Configuration, you'll get a message telling you that no flasks are selected.

### Flasks vs Elixirs

Flasks and Elixirs are mutually exclusive - you can't have both active at the same time. SpyingGnome reflects this:

- If you check "Check for missing Flasks", the Battle Elixirs and Guardian Elixirs checkboxes will automatically uncheck
- If you check either "Check for missing Battle Elixirs" or "Check for missing Guardian Elixirs", the Flasks checkbox will automatically uncheck

This prevents confusion and ensures you're checking for the right type of consumable.

## Understanding the Messages

### Personal Chat Messages

When you perform a check, you'll see messages like this in your chat:

```
[SG] Missing food: Player1, Player2.
[SG] Missing flask: Player1, Player2.
```

These messages show (Depending on your configuration):
- What's missing (food, flask, elixir, protection buffs)
- Which players are missing that consumable (names in color)

### Raid Chat Messages

If you're a Raid Leader or Officer with raid chat enabled, messages will appear in raid chat like this (Given, that you choose "Enable Status Printing to Raid Chat):

```
[R] [RaidLeader1]: [SG] Missing flask: Player1, Player2
[R] [RaidLeader1]: [SG] Missing food buff: Player1, Player2
```

The `[SG]` prefix identifies these as SpyingGnome messages.

### Protection Buff Messages

When checking for protection potions, you'll see these two types of messages for each protection type that's enabled:

```
[SG] Missing Fire Protection: Player1.
[R] [RaidLeader1]: [SG] Missing Fire Protection: Player1.
```

### Elixir Messages

Battle Elixirs and Guardian Elixirs are reported separately:

```
[R] [RaidLeader1]: [SG] Missing Battle Elixir: Player1
[R] [RaidLeader1]: [SG] Missing Guardian Elixir: Player1, Player2
```

- In this case, Player 2 has a Battle Elixir buff, but not a Guardian Elixir buff.

### Success Message

When everyone has all the required consumables, you'll see:

```
[SG] All raiders meet the configured consumable criteria.
```

This message appears in raid chat (if enabled) when you're a Raid Leader or Officer.

## Tips and Best Practices

### For Raid Leaders and Officers

1. **Only One Person Should Have Raid Chat Enabled** - To avoid spam, only the Raid Leader or one Officer should have "Enable Status Report Printing in Raid Chat" checked.

2. **Configure Before Raid** - Set up your consumable preferences before the raid starts. Decide which flasks/elixirs and protections you want to require.

3. **Use Ready Check Integration** - Enable "Print to raid chat after a ready check" to automatically check consumables right before pulls.

## Supported Consumables

### Flasks
- Flask of Chromatic Resistance
- Flask of Distilled Wisdom
- Flask of the Titans
- Flask of Overwhelming Might
- Flask of Supreme Power

### Battle Elixirs
- Elixir of the Mongoose
- Elixir of Shadow Power
- Elixir of Greater Firepower
- Elixir of Giants
- Elixir of Pure Arcane Power
- Elixir of Dazzling Light
- Greater Arcane Elixir
- Elixir of Brute Force
- Winterfall Firewater
- Ground Scorpok Assay
- R.O.I.D.S.
- Juju Power
- Juju Might

### Guardian Elixirs
- Elixir of Greater Intellect
- Elixir of the Sages
- Elixir of Superior Defense
- Elixir of Fortitude
- Lung Juice Cocktail
- Cerebral Cortex Compound
- Gizzard Gum
- Juju Guile

### Food Buffs
- Well Fed (any food that provides this buff)
- Nightfin Soup
- Protein Shake
- Grilled Squid
- Rumsey Rum Black Label

### Protection Potions
- Arcane Protection
- Fire Protection
- Frost Protection
- Holy Protection
- Nature Protection
- Shadow Protection

- If any are missing that you know of, please contact me below.

## Special Features

### Tooltips

Hover over any of the flasks/elixirs/protections mentioned in the Configuration window to see the respective item's tooltip.

## Troubleshooting

### "You are not in a raid party"
- Make sure you're actually in a raid group, not just a party.

### "You have not selected any [consumable type] to check for"
- You've enabled checking for a consumable type (like Flasks) in the main window, but haven't selected any specific items in the Configuration window.
- Go to Configuration and check the specific flasks/elixirs/protections you want to monitor.

### Messages Not Appearing in Raid Chat
- Make sure you're a Raid Leader or Raid Officer (regular raiders can't send status reports to raid chat).
- Check that "Enable Status Report Printing in Raid Chat" is enabled.

### Messages Appearing Twice
- This shouldn't happen. Please contact me below.

## Contact & Support

If you find that some flasks, elixirs, or other consumables are missing from the list, or if you have suggestions for improvements, please reach out!

<img width="90" height="23" alt="Epoch_Logo" src="https://github.com/user-attachments/assets/bf507725-5c0e-4dec-aae6-54784510eaa4" />Mightbeard _(Kezan)_ 

<img width="32" height="32" alt="discordlogo" src="https://github.com/user-attachments/assets/b12f7d5c-1e58-405a-a2d0-87358e452cd8" />Turbi

**Happy raiding!**

### Special Thanks

Thank you to all the contributors and testers: Norelenilia, Skarr, Kerian, Nickfury, Kazlyn, Surcouf, Thraxeus, Eeveel, Kybalion & the Kezan Community Discord

---

## Version History

## SpyingGnome v1.3.2

### Behavior Changes
- **Flasks Count as Elixirs**: Battle Elixir and Guardian Elixir checks now also accept flasks as valid. Since flasks and elixirs are mutually exclusive in-game, players with a flask will now pass both Battle Elixir and Guardian Elixir checks, making the addon work better for raids that use flasks and elixirs.

## SpyingGnome v1.3.1

### New Features
- **New Elixirs Added**:
  - Juju Power (Battle Elixir)
  - Juju Might (Battle Elixir)
  - Juju Guile (Guardian Elixir)
- **New Food Buffs Added**:
  - Rumsey Rum Black Label

### Interface Changes
- Added version number (v1.3.1) to the addon name in the main configuration window.

### Other Changes
- Readme -file cleanup, more sensible and easier to read. Proper documentation.

## SpyingGnome v1.3

### New Features
- **Guardian Elixirs Support**: Added separate tracking for Guardian Elixirs
- **Elixir Categories**: Split elixirs into Battle Elixirs and Guardian Elixirs categories
- **New Elixirs Added**: 
  - Elixir of Brute Force (Battle Elixir)
  - Elixir of Superior Defense (Guardian Elixir)
  - Elixir of Fortitude (Guardian Elixir)
  - Lung Juice Cocktail (Guardian Elixir)
  - Winterfall Firewater (Battle Elixir)
  - Ground Scorpok Assay (Battle Elixir)
  - R.O.I.D.S. (Battle Elixir)
  - Cerebral Cortex Compound (Guardian Elixir)
  - Gizzard Gum (Guardian Elixir)
- **New Food Buffs Added**:
  - Nightfin Soup
  - Protein Shake
  - Grilled Squid
- A second gnome has made an appearance! _(Thank you Surcouf!)_

## SpyingGnome v1.2 / The Great Raidening
- UI rework, added "Configuration" menu.

<img width="275" height="425" alt="image" src="https://github.com/user-attachments/assets/9a9ff611-0fec-4025-87eb-e1c44558b1bf" />

- The addon now crossreferences everything under "Configuration" towards the checks, and checks players for said consumables. You may choose to check for certain consumables only through this.

<img width="275" height="425" alt="image" src="https://github.com/user-attachments/assets/d39e706f-3aaa-40c6-8bba-2e9369593e2e" />

- Each consumable has a tooltip now! And a short (+XX stat) after each potion, colored.

<img width="661" height="324" alt="image" src="https://github.com/user-attachments/assets/0ee58677-3691-4163-a591-7c032ad43b26" />

- Added **high-end Elixirs** table as an **optional** choice, dependant "Check for missing flasks".
- If you perform a check with Elixirs enabled, it will not print out the name in a flask check if a player has an elixir buff active.

<img width="275" height="425" alt="image" src="https://github.com/user-attachments/assets/e7c380b5-aa87-4174-875f-bf0e33fb6b97" />
<img width="382" height="39" alt="image" src="https://github.com/user-attachments/assets/593300ec-c459-4cb5-add5-ea7f36799626" />

<details>
<summary>List of accepted Elixirs</summary>
<ul><li> Elixir of the Mongoose</li>
<li> Elixir of the Sages</li>
<li> Elixir of Shadow Power</li>
<li> Elixir of Greater Firepower</li>
<li> Elixir of the Giants</li>
<li> Elixir of Greater Intellect</li>
<li> Elixir of Pure Arcane Power</li>
<li> Elixir of Dazzling Light</li>
<li> Greater Arcane Elixir</li></ul>
</details>

- Updated localization to match Elixir criteria in status reports

## SpyingGnome v1.1
- Adjustments to the UI, added a "Enable SpyingGnome" checkbox.

![Ascension_LVTcBvfIZZ](https://github.com/user-attachments/assets/e9eaeed6-38f0-44de-83f6-3780b1d0505d)

- Updated debug print/raid chat print logic, you can get the debug message as a raider. Raid announcements are limited to Raid Leader / Raid Officer.
