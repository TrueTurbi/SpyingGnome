# SpyingGnome
A fully configurable Flask/Elixir/Food/Prot buff checker for Project Epoch.

<img width="275" height="450" alt="image" src="https://github.com/user-attachments/assets/0cc6ded5-87d9-42a7-9e30-f0ce7be02709" /> <img width="330" height="500" alt="image" src="https://github.com/user-attachments/assets/f129e641-1eee-462b-bf9b-57e22844aa0e" />

The addon is a configurable buff checker for your raids. This addon will only work, if you're in a raid group.

**NOTE:** Raid Chat printing is limited to Raid Leader and Raid Officer roles to avoid clutter. Only Raid Leader OR Raid Officer should have raid chat printing enabled.

# Documentation

To use this addon, use commands:

**/sg**

**/spyinggnome**

You always get a print out in chat (Unless you have "SpyingGnome Enabled" unchecked):

<img width="272" height="35" alt="image" src="https://github.com/user-attachments/assets/24bb80cc-733b-4518-bd18-04b84ff9fc37" />

And if you check "Enable Status Report Printing in Raid Chat" and "Print to raid chat after a ready check", you can do a check with a raid chat announcement by using the button or ready check in /sg:

<img width="322" height="316" alt="image" src="https://github.com/user-attachments/assets/b7b18abc-4e71-4135-a9fc-7f9c1ae43641" />

Button in /sg:

<img width="448" height="37" alt="image" src="https://github.com/user-attachments/assets/5dfeb307-5822-4bad-896b-5b531468671a" />

Ready check status print after ready check is complete:

<img width="448" height="37" alt="image" src="https://github.com/user-attachments/assets/52167c98-dc24-4f0c-9027-96cc1984da21" />

Without "Enable Status Report Printing in Raid Chat" checked, pressing "Perform check":

<img width="336" height="39" alt="image" src="https://github.com/user-attachments/assets/32f2981e-90ca-4452-b62f-2f252f99e72e" />

I also added protection potions, to check if everyone has pre-potted. Added all protection types for possible future-proofing:

<img width="229" height="206" alt="image" src="https://github.com/user-attachments/assets/c539dd27-fd28-4fde-a590-87d13b5e2d53" />
<img width="264" height="34" alt="image" src="https://github.com/user-attachments/assets/daa4f397-d771-45fe-ba98-62c42e7119fe" />

After clicking the button in /sg:

<img width="409" height="36" alt="image" src="https://github.com/user-attachments/assets/0c54fd6c-a6ea-4f3d-9272-9be33573b6b5" />

Now also supporting Elixirs (Battle Elixirs and Guardian Elixirs separately):

<img width="264" height="79" alt="image" src="https://github.com/user-attachments/assets/81429da6-e048-451e-9964-54c6bd3d0c21" />

With a new report, if Guardian and Battle Elixir check enabled:

<img width="476" height="37" alt="image" src="https://github.com/user-attachments/assets/e0dffa24-847f-411f-be0d-81ae4e930d61" />


# Contact

If some flasks are missing from the list, contact me below!
Any suggestions for improvements are welcome!

You may contact me in-game or through Discord:

**In-game:** Mightbeard

**Discord:** Turbi

**Happy raiding!**

**Special Thanks to:** Norelenilia, Skarr, Kerian, Nickfury, Kazlyn, Surcouf, Thraxeus, Eeveel, Kybalion & the Kezan Community Discord

# SpyingGnome v1.3

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

### Interface Changes
- Renamed "Check for missing elixirs" to "Check for missing Battle Elixirs"
- Added new "Check for missing Guardian Elixirs" checkbox
- Updated checkbox labels with proper capitalization
- Added tooltips to Protection buffs (hover to see item details)
- Reordered elixirs in Configuration window: Ground Scorpok Assay and R.O.I.D.S. appear at the bottom of Battle Elixirs, Cerebral Cortex Compound and Gizzard Gum appear at the bottom of Guardian Elixirs

### Message Updates
- Debug messages now include [SG] prefix
- Added separate messages for Battle Elixirs and Guardian Elixirs
- Changed "Missing Flask" to "Missing flask:" in all messages
- Updated success message: "All raiders meet the configured consumable criteria"
- Added warning when no checks are selected: "You have not selected any checks. Check your configuration"
- Added message when not in raid: "You are not in a raid party"

### Behavior Changes
- **Mutual Exclusivity**: Flasks and Elixirs checkboxes are now mutually exclusive - checking one automatically unchecks the other
  - If you check "Check for missing Flasks", Battle Elixirs and Guardian Elixirs are automatically unchecked
  - If you check "Check for missing Battle Elixirs" or "Check for missing Guardian Elixirs", Flasks is automatically unchecked
- Debug printing now respects "Enable Status Report Printing in Raid Chat" setting (prints to debug if enabled but player is not raid leader/officer)
- Status reports print in order: Flask, Battle Elixir, Guardian Elixir, Food, Protection
- Battle Elixirs and Guardian Elixirs are checked and reported independently
- Success message sent to raid chat when all checks pass (raid leader/officer only)

# SpyingGnome v1.2 / The Great Raidening
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

# SpyingGnome v1.1
- Adjustments to the UI, added a "Enable SpyingGnome" checkbox.

![Ascension_LVTcBvfIZZ](https://github.com/user-attachments/assets/e9eaeed6-38f0-44de-83f6-3780b1d0505d)

- Updated debug print/raid chat print logic, you can get the debug message as a raider. Raid announcements are limited to Raid Leader / Raid Officer.
