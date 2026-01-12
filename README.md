# SpyingGnome
A fully configurable Flask/Elixir/Food/Prot buff checker for Project Epoch.

<img width="300" height="450" alt="image" src="https://github.com/user-attachments/assets/9a9ff611-0fec-4025-87eb-e1c44558b1bf" /> <img width="300" height="450" alt="image" src="https://github.com/user-attachments/assets/d39e706f-3aaa-40c6-8bba-2e9369593e2e" />

The addon is a configurable buff checker for your raids. This addon will only work, if you're in a raid group.

**NOTE:** Raid Chat printing is limited to Raid Leader and Raid Officer roles to avoid clutter. Only Raid Leader OR Raid Officer should have raid chat printing enabled.

# Addon Usage

To use this addon, use commands:

**/sg**

**/spyinggnome**

You always get a print out in chat (Unless you have "SpyingGnome Enabled" unchecked):

<img width="272" height="35" alt="image" src="https://github.com/user-attachments/assets/24bb80cc-733b-4518-bd18-04b84ff9fc37" />

And if you check "Enable Status Report Printing in Raid Chat" and "Print to raid chat after a ready check", you can do a check with a raid chat announcement by using the button or ready check in /sg:

<img width="275" height="425" alt="image" src="https://github.com/user-attachments/assets/b7574c19-5aa2-425b-b8af-35832a4d20c0" />

Button in /sg:

<img width="432" height="67" alt="image" src="https://github.com/user-attachments/assets/8fba8790-9e76-41c9-97f2-fb48aefbca63" />

Ready check status print after ready check is complete:

<img width="420" height="114" alt="image" src="https://github.com/user-attachments/assets/f6e370ea-13fc-4dd8-b272-8e654892334a" />

I also added protection potions, to check if everyone has pre-potted. Added all protection types for possible future-proofing:

<img width="229" height="206" alt="image" src="https://github.com/user-attachments/assets/c539dd27-fd28-4fde-a590-87d13b5e2d53" />
<img width="264" height="34" alt="image" src="https://github.com/user-attachments/assets/daa4f397-d771-45fe-ba98-62c42e7119fe" />

After clicking the button in /sg:

<img width="409" height="36" alt="image" src="https://github.com/user-attachments/assets/0c54fd6c-a6ea-4f3d-9272-9be33573b6b5" />

Now also supporting Elixirs:

<img width="222" height="75" alt="image" src="https://github.com/user-attachments/assets/699afc76-2735-475f-a805-35bba0194058" />

With a new report, if Elixir check enabled _(It will count Elixir towards Flasks, if enabled.)_:

<img width="379" height="38" alt="image" src="https://github.com/user-attachments/assets/e6539479-7843-44c0-9fc3-4035486c3f8f" />

# Contact

If some flasks are missing from the list, contact me below!
Any suggestions for improvements are welcome!

You may contact me in-game or through Discord:

**In-game:** Mightbeard

**Discord:** Turbi

**Happy raiding!**

**Credits/Special Thanks for providing assistance:** Norelenilia, Skarr, Kerian, Nickfury, Kazlyn, Kybalion & Kezan Community Discord

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
<li> Spirit of Zanza</li>
<li> Elixir of Brute Force</li>
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
